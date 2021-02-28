include("../src/includes.jl")

queue!(chan -> source!(chan, "testQueue", String) |>
safe_map_ack!(String, msg -> msg != "bye" ? msg : error("bye"), (e) -> ()) |>
sink!(msg -> ()))

queue!(chan -> source!(chan, "test1Queue", Dict{String,Any}) |>
sink!(msg -> ()))

tasks = execute_queues!()

readline()

println(fetch(tasks[1]))
println(fetch(tasks[2]))
