include("constants.jl")

function init_config!()
    project_root = pwd()
    from_location = joinpath(PKG_ROOT, NEW_APP_PATH)
    template_struct = joinpath(from_location,"*")
    println(project_root)
    println(from_location)
    dir_cp(template_struct, project_root)
end

function dir_cp(src::String, dest::String)
    for (root, dirs, files) in walkdir(src)
        mkdir(joinpath(dest, basename(root)))
        for file in files
            cp(joinpath(root,file), joinpath(dest,file))
        end
    end
end
