abstract type AmqpSink end

struct OutConnection
    out_conn
    open_chans::Vector{AmqpSink}
    OutConnection(_conn_def) = begin
        out_conn = connection!(_conn_def)
        new(out_conn, [])
    end
end

_out_conn = nothing
open_sink_conn!() = global _out_conn = OutConnection(_conn_def)
close_sink_conn!() = close_connection!(_out_conn.out_conn)
is_sink_conn_open() = _out_conn == nothing ? false : isopen(_out_conn.out_conn)

struct DlqSink <: AmqpSink
    name::String
    sendFn::Function
    closeFn::Function
    DlqSink(name, chan) = begin
        sendFn = msg -> send!(chan, DLQ_EXCHANGE, msg, name)
        closeFn = () -> close_channel!(chan)
        dlq_amqp_config!(chan, name)
        new(name, sendFn, closeFn)
    end
end

function dlq_sink!(basename::String)
    name = basename * "-dlq"
    chan = channel!(_out_conn.out_conn)
    sink = DlqSink(name, chan)
    push!(_out_conn.open_chans, sink)
    sink
end

struct ExchangeSink <: AmqpSink
    name::String
    sendFn::Function
    closeFn::Function
    ExchangeSink(name, chan) = begin
        sendFn = msg -> send!(chan, name, msg)
        closeFn = () -> close_channel!(chan)
        publisher_amqp_config!(chan,name)
        new(name, sendFn, closeFn)
    end
end

close!(sink::AmqpSink) = sink.closeFn()

function exchange_sink!(name::String)
    chan = channel!(_out_conn.out_conn)
    sink = ExchangeSink(name, chan)
    push!(_out_conn.open_chans, sink)
    sink
end

function sink!(exchange_name::String)
    if !is_sink_conn_open()
        open_sink_conn!()
    end
    exchange_sink = exchange_sink!(exchange_name)
    sink!(val -> exchange_sink.sendFn(val))
end
