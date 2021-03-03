using Rocket

abstract type Source{T} end

struct FlowError <: Exception
    cause::Exception
    dlFn::Function
    ackFn::Function
end

function source!(src::Source{T}) where T
    make(T) do consumer
        start_consume!(src,consumer)
    end
end

struct AckUnit{T}
    val::T
    dlFn::Function
    ackFn::Function
end

val(unit::AckUnit{T} where T) = unit.val
ack(unit::AckUnit{T} where T) = unit.ackFn()

val(unit::Any) = unit
ack(unit::Any) = nothing

ack_source!(src::Source{T}) where T =
    source!(src) |> map(AckUnit{T}, AckUnit(T, src))

map_ack(::Type{R}, mappingFn::F) where {R, F<:Function} =
    Rocket.map(AckUnit{R}, unit -> AckUnit{R}(mappingFn(unit.val), unit.dlFn, unit.ackFn))

function unsafe_map_ack(::Type{R}, unsafeFn::F) where {R, F<:Function}
    Rocket.map(AckUnit{R}, unit -> try
        AckUnit{R}(unsafeFn(unit.val), unit.dlFn, unit.ackFn)
    catch e
        throw(FlowError(e, unit.dlFn, unit.ackFn))
    end)
end

function maybe_dlq!(logFn::Function)
    catch_error((err,src) -> (err.dlFn(); logFn(err.cause); src))
end

safe_map_ack!(::Type{R}, unsafeFn::Function, logFn::Function=(c)->Nothing) where R =
    safe() |> unsafe_map_ack(R, unsafeFn) |> maybe_dlq!(logFn)

function start_consume!(src::Source{T}, consumer) where T
    while true
        msg = src.pollFn()
        if !isnothing(msg)
            next!(consumer, msg)
        else
            yield()
        end
    end
end

ack_sink!() = unit -> (unit.ackFn(); Nothing)

function handle!(source, fun::Function)
    subscribe!(source, lambda(on_next = msg -> fun(msg)))
end

Base.:|>(source, successFn::Function) = handle!(source, successFn)

sink!(sinkFn::Function) = unit -> (sinkFn(val(unit));ack(unit))
