include("InitFiles.jl")
include("AmqpConfigLoad.jl")

try
    loadConfig()
catch e
    if isa(e, FileNotFoundError)
        @info "Config file not found at: " * e.path
    else
        throw(e)
    end
end

if isfile(QUEUES_FILE_PATH)
    include(QUEUES_FILE_PATH)
    _queue_Tasks = execute_queues!()
end
