module ReactiveAmqp

include("includes.jl")

export AmqpConnectionDef, compose_auth, amqp_conn_define!
export source!, queue!, execute_queues!
export map_ack, safe_map_ack!, sink!
export init_config!

end
