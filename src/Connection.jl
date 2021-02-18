using AMQPClient
using MbedTLS

function compose_auth(user::String,password::String)
    Dict{String,Any}("MECHANISM"=>"AMQPLAIN", "LOGIN"=>user, "PASSWORD"=>password)
end

struct AmqpConnectionDef
    virtualhost::String
    host::String
    port::Int64
    auth_params::Dict{String,Any}
    amqps::Union{Nothing, MbedTLS.SSLConfig}
    AmqpConnectionDef(host,auth_params) = new("/",host,AMQPClient.AMQP_DEFAULT_PORT,auth_params,Nothing())
end

function AMQPClient.connection(conn_def::AmqpConnectionDef)
    connection(; virtualhost=conn_def.virtualhost, host=conn_def.host, port=conn_def.port, auth_params=conn_def.auth_params, amqps=conn_def.amqps)
end

function close_connection(conn)
    if isopen(conn)
        close(conn)
        AMQPClient.wait_for_state(conn, AMQPClient.CONN_STATE_CLOSED)
    end
end

function amqp_connection(f::Function, conn_def::AmqpConnectionDef)
    conn = connection(conn_def)
    try
        f(conn)
    finally
        close_connection(conn)
    end
end
