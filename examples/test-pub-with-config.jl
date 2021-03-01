include("../src/includes.jl")

function publisher_amqp_config!(chan, exchangename)
    vent_queue = exchangename * "-vent"
    declare_exchange!(chan, exchangename, EXCHANGE_TYPE_FANOUT)
    declare_queue!(chan, vent_queue)
    queue_bind(chan, vent_queue, exchangename, "*")
end

struct ExchangeSinkBuilder
    name::String
    in_chan::Channel
end

struct ExchangeSink
    name::String
    sendFn::Function
    pollFn::Function
    ExchangeSink(chann, builder) = begin
        name = builder.name
        in_chan = builder.in_chan
        sendFn = msg -> send!(chan, name, msg)
        pollFn = () -> isready(in_chan) ? take!(in_chan) : nothing
        publisher_amqp_config!(chan,name)
        new(name, sendFn)
    end
end

_exchange_sink_builders = []

function sink!(exchange_name::String, buffer_size::Int32=32)
    sink_chan = Channel(buffer_size)
    push!(_exchange_sink_builders, ExchangeSinkBuilder(exchange_name, sink_chan))
    sink!(val -> put!(sink_chan, val))
end

const TEST_EXCHANGE = "testExchange"

struct IntSource <: Source{Int}
    pollFn::Function
    IntSource(coll) = new(pop!(coll))
end

v = collect(1:10000)

function start_sinks!()
    tasks = Task[]
    begin
        amqp_connection!(_conn_def) do conn
            for exchange_builder in _exchange_sink_builders
                amqp_channel!(conn) do chan
                    sink = ExchangeSink(exchange_builder)
                    while true
                        msg = sink.pollFn()
                        if isnothing(msg)
                            sink.sendFn(msg)
                        else
                            yield()
                        end
                    end
                end
            end
        end
    end
end

@async source!(v) |> sink!("testQueue")
start_sinks!()
readline()
