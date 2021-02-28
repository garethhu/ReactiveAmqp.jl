include("InitFiles.jl")
include("AmqpConfigLoad.jl")

try
    loadConfig()
catch e::FileNotFoundError
    @info "Config file not found at: " * e.filepath
end
