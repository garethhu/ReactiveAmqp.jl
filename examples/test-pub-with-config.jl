include("../src/includes.jl")

const TEST_EXCHANGE = "testExchange"

struct IntSource <: Source{Int}
    pollFn::Function
    IntSource(coll) = new(() -> length(v) > 0 ? pop!(coll) : nothing)
end

v = collect(1:10000)

@async source!(IntSource(v)) |> sink!("testExchange")

readline()
