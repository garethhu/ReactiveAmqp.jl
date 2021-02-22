using AMQPClient

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

compose(message::T where T) = Message(serialize(message), content_type="text/plain", delivery_mode=PERSISTENT)

send!(chan,exchange::String, message::T where T, routing_key::String) =
    basic_publish(chan, compose(message); exchange=exchange, routing_key=routing_key)

send!(chan,exchange::String, message::T where T) =
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

queue_source!(chan, name::String) = ack_source!(QueueSource(chan, name))

_flows = []

flow(flow::Function) = push!(_flows, flow)

function execute_queues!(conn_def)
    @async begin
        amqp_connection!(conn_def) do conn
            amqp_channel!(conn) do chan
                Threads.@spawn for _flow in _flows
                    _flow(chan)
                end
            end
        end
    end
end
