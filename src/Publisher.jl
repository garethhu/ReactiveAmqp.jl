function publisher_amqp_config!(chan, exchangename)
    vent_queue = exchangename * "-vent"
    declare_exchange!(chan, exchangename, EXCHANGE_TYPE_FANOUT)
    declare_queue!(chan, vent_queue)
    queue_bind(chan, vent_queue, exchangename, "*")
end

struct OutConnection
    out_conn
    open_chans::Vector{ExchangeSink}
    OutConnection(_conn_def) = begin
        out_conn = connection!(_conn_def)
        new(out_conn, [])
    end
end

_out_conn = nothing
open_sink_conn!() = global _out_conn = OutConnection(_conn_def)
close_sink_conn!() = close_connection!(_out_conn.out_conn)
is_sink_conn_open() = _out_conn == nothing ? false : isopen(_out_conn.out_conn)
