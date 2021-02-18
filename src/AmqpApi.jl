module AmqpApi

using AMQPClient
using MbedTLS

export AmqpConnectionDef, amqp_connection, amqp_channel, declare_queue

struct AmqpConnectionDef
    virtualhost::String
    host::String
    port::Int64
    auth_params::Dict{String,Any}
    amqps::Union{Nothing, MbedTLS.SSLConfig}
    AmqpConnectionDef(host,port,auth_params) = new("/",host,AMQPClient.AMQP_DEFAULT_PORT,auth_params,Nothing())
end

function AMQPClient.connection(conn_def::ConnectionDef)
    connection(; virtualhost=conn_def.virtualhost, host=conn_def.host, port=conn_def.port, auth_params=conn_def.auth_params, amqps=conn_def.amqps)
end

function close_connection(conn)
    if isopen(conn)
        close(conn)
        AMQPClient.wait_for_state(conn, AMQPClient.CONN_STATE_CLOSED)
    end
end

function amqp_connection(f::Function, conn_def::ConnectionDef)
    conn = connection(conn_def)
    try
        f(conn)
    finally
        close_connection(conn)
    end
end

function AMQPClient.channel(conn)
    channel(conn, AMQPClient.UNUSED_CHANNEL, true)
end

function close_channel(chan)
    if isopen(chan)
        close(chan)
        AMQPClient.wait_for_state(chan, AMQPClient.CONN_STATE_CLOSED)
    end
end

function amqp_channel(f::Function, conn)
    chan = channel(conn)
    try
        f(chan)
    finally
        close_channel(chan)
    end
end

struct QueueDeclarationError <: Exception
    queue_name::String
end

function declare_queue(chan, queue)
    success, queue_name, message_count, consumer_count = queue_declare(chan, queue)
    success || throw(QueueDeclarationError(queue_name))
end

end
