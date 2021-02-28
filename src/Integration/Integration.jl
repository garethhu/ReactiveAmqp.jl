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
