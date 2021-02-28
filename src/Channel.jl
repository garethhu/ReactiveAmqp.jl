using AMQPClient

channel!(conn) =
    channel(conn, AMQPClient.UNUSED_CHANNEL, true)


function close_channel!(chan)
    if isopen(chan)
        close(chan)
        AMQPClient.wait_for_state(chan, AMQPClient.CONN_STATE_CLOSED)
    end
end

function amqp_channel!(f::Function, conn)
    chan = channel!(conn)
    try
        f(chan)
    finally
        close_channel!(chan)
    end
end
