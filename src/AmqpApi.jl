module AmqpApi

include("Connection.jl")
include("Channel.jl")
include("Exchange.jl")
include("Queue.jl")
include("Reactive.jl")

export AmqpConnectionDef, compose_auth
export queue_source!, execute_single_queue!
export map_ack, safe_map_ack!

function consumer_amqp_config!(chan, name, dlq)
    declare_queue!(chan, name)
    declare_exchange!(chan, DLQ_EXCHANGE, EXCHANGE_TYPE_DIRECT)
    declare_queue!(chan, dlq)
    queue_bind(chan, dlq, DLQ_EXCHANGE, dlq)
end

function execute_single_queue!(queue::Function)
    amqp_connection!(conn_def) do conn
        amqp_channel!(conn) do chan
            queue(chan)
        end
    end
end

end
