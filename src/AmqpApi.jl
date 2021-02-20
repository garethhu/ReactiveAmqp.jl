module AmqpApi

include("Connection.jl")
include("Channel.jl")
include("Exchange.jl")
include("Queue.jl")
include("Reactive.jl")
include("Consumer.jl")

export AmqpConnectionDef, compose_auth
export queue_source!, execute_single_queue!
export map_ack, safe_map_ack!

end
