using AMQPClient

struct ExchangeDeclarationError <: Exception
    exchange_name::String
end

function declare_exchange!(chan, exchange_name, type)
    success = exchange_declare(chan, exchange_name, type)
    success || throw(ExchangeDeclarationError(exchange_name))
    exchange_name
end

struct ExchangeSink
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

close!(exchange_sink::ExchangeSink) = exchange_sink.closeFn()

function exchange_sink!(name::String)
    chan = channel!(_out_conn.out_conn)
    sink = ExchangeSink(name, chan)
    push!(_out_conn.open_chans, sink)
    sink
end

function sink!(exchange_name::String)
    exchange_sink = exchange_sink!(exchange_name)
    sink!(val -> exchange_sink.sendFn(val))
end
