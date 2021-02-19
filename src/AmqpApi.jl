module AmqpApi

include("Connection.jl")
include("Channel.jl")
include("Exchange.jl")
include("Queue.jl")

export AmqpConnectionDef, compose_auth, amqp_connection!, amqp_channel!, declare_queue!, send!, declare_exchange!
end
