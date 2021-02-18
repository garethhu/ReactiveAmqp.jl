using AMQPClient

struct QueueDeclarationError <: Exception
    queue_name::String
end

function declare_queue(chan, queue)
    success, queue_name, message_count, consumer_count = queue_declare(chan, queue)
    success || throw(QueueDeclarationError(queue_name))
end
