# ReactiveAmqp.jl

## Introduction
This Julia package is a reactive API for interacting with an AMQP connection. It handles establishing a connection to an AMQP client, using the AMQPClient package, with the added convenience of yaml config support and an elegant way to define data processing flows, leveraging the reactive Rocket.jl API to provide push pull publisher subscriber interaction. The flows handle acking back to the AMQP client upon fully processing a message, and provides convenient error handling.

## Usage
From your project root directory run:
```julia
using ReactiveAmqp
init_config!()
```


This will generate an amqp directory in the project directory with a connection.yaml file within in, in which you can define the parameters of environment specific configurations, defaulting to 'dev'. It will also generate a 'queues.jl' file in which you can place queue definitions, sutch that their execution is managed by the ReactiveAmqp package.

Queues can be defined in the following way:

```julia
queue!(chan -> source!(chan, "testQueue", String) |>
map_ack!(String, msg -> lowercase(msg))
safe_map_ack!(String, msg -> msg != "bye" ? msg : error("bye"), (e) -> ()) |>
sink!(msg -> println(msg)))
```


In the above example we get a string source from a queue called 'testQueue', we then convert it to lowercase and if the message is bye, then we raise an error, which will result in a DLQ message to the testQueue-dlq queue, we then print the message. The flow handles acking back to the AMQP client queue on successful completion of the sink function, or successful posting to the DLQ. 

Note: the types provided as the first argument of the map functions is the return type of the supplied function.

Other data types are also supported by the `source!` function, including JSON, DataFrames, and Julia data types. For Dataframe and Julia types, the messages from the AMQP cient are deserialised as JSON for compatibility, so submissions for these source types to the client should be JSON.

JSON: 
```julia 
source!(chan, "test1Queue", Dict{String,Any})
```

DataFrame: 
```julia 
source!(chan, "test1Queue", DataFrame)
```

Julia Types: 
```julia 
source!(chan, "test1Queue", T)
```

To use a queue as a sink you can use the following, instead of providing a sink function:

```julia
sink!("testExchange")
````

## Additional Information
The configuration file can be overriden by defining the 'AMQP_CONN_FILE_PATH' environment variable. The envirnment can be set using the  `AMQP_ENV` environment variable.
