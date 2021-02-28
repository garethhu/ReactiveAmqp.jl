include("InitFiles.jl")
include("AmqpConfigLoad.jl")

try
    loadConfig()
catch e
    if isa(e, FileNotFoundError)
        @info "Config file not found at: " * e.filepath
    else
        throw(e)
    end
end
