include("../src/includes.jl")

user = "guest"  # default is usually "guest"
password = "guest"  # default is usually "guest"
auth_params = compose_auth(user,password)
host="127.0.0.1"
conn_def = AmqpConnectionDef(host,auth_params)

amqp_conn_define!(conn_def)

queue!(chan -> source!(chan, "testQueue", String) |>
safe_map_ack!(String, msg -> msg != "bye" ? msg : error("bye"), (e) -> ()) |>
sink!(msg -> ()))

queue!(chan -> source!(chan, "test1Queue", Dict{String,Any}) |>
sink!(msg -> ()))

tasks = execute_queues!()

readline()

println(fetch(tasks[1]))
println(fetch(tasks[2]))
