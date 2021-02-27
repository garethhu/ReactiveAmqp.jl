module ReactiveAmqp

include("ReactiveFlows.jl")
include("Connection.jl")
include("Channel.jl")
include("Exchange.jl")
include("Queue.jl")
include("Consumer.jl")

export AmqpConnectionDef, compose_auth, amqp_conn_define!
export source!, queue!, execute_queues!
export map_ack, safe_map_ack!, sink!

end
