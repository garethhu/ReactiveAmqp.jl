using AMQPClient

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
