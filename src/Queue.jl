using AMQPClient
using JSON
using Unmarshal
using DataFrames

const DLQ_EXCHANGE = "DLQ"

struct QueueDeclarationError <: Exception
    queue_name::String
end

function declare_queue!(chan, queue)
    success, queue_name, message_count, consumer_count = queue_declare(chan, queue)
    success || throw(QueueDeclarationError(queue_name))
    queue_name
end

serialize(serializable::Vector{UInt8}) = serializable
serialize(serializable::String) = Vector{UInt8}(serializable)
serialize(serializable::Int) = serialize(string(serializable))

compose(message::T where T) = Message(serialize(message), content_type="text/plain", delivery_mode=PERSISTENT)

send!(chan,exchange::String, message::T where T, routing_key::String) =
    basic_publish(chan, compose(message); exchange=exchange, routing_key=routing_key)

send!(chan, exchange::String, message::T where T) =
    send!(chan,exchange, message, "*")

AckUnit(::Type{Message}, src) =
    msg::Message -> AckUnit{Message}(msg, () -> src.dlFn(msg.data,msg.delivery_tag), () -> src.ackFn(msg.delivery_tag))

struct QueueSource <: Source{Message}
    name::String
    dlq::String
    pollFn::Function
    dlFn::Function
    ackFn::Function
    QueueSource(chan, name) = begin
        dlq = name * "-dlq"
        consumer_amqp_config!(chan, name, dlq)
        pollFn = () -> basic_get(chan, name, false)
        ackFn = ack_handle -> basic_ack(chan, ack_handle)
        dlFn = (msg_data, ack_handle) -> (send!(chan, DLQ_EXCHANGE, msg_data, dlq); ackFn(ack_handle))
        new(name, dlq, pollFn, dlFn, ackFn)
    end
end

source!(chan, name::String) = ack_source!(QueueSource(chan, name))
source!(chan, name::String, type::Type{String}) = source!(chan, name) |> map_ack(String, msg -> String(msg.data))
source!(chan, name::String, type::Type{Dict{String,Any}}) = source!(chan, name, String) |> safe_map_ack!(Dict{String,Any}, msg -> JSON.parse(msg))
source!(chan, name::String, type::Type{DataFrame}) = source!(chan, name, Dict{String,Any}) |> safe_map_ack!(DataFrame, msg -> DataFrame(msg))
source!(chan, name::String, unmar::Type{T}) where T = source!(chan, name, Dict{String,Any}) |> safe_map_ack!(type, msg -> Unmarshal.unmarshal(type, msg))

_queues = []

queue!(queue::Function) = push!(_queues, queue)

function execute_queues!()
    tasks = Task[]
    @async begin
        amqp_connection!(_conn_def) do conn
            @sync for queue in _queues
                 @async push!(tasks,
                    Threads.@spawn amqp_channel!(conn) do chan
                        queue(chan)
                    end)
            end

        end
    end
    return tasks
end
