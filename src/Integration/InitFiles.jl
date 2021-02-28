include("constants.jl")

function init_config!()
    project_root = dirname(@__DIR__)
    from_location = joinpath(PKG_ROOT, NEW_APP_PATH)
    template_struct = joinpath(from_location,"*")
    println(project_root)
    println(from_location)
    cp(template_struct, project_root)
end
