include("constants.jl")

function init_config!()
    from_location = joinpath(PKG_ROOT, NEW_APP_PATH)
    dir_cp(from_location, PROJ_ROOT)
end

function dir_cp(src::String, dest::String)
    for (root, dirs, files) in walkdir(src)
        for dir in dirs
            mkdir(joinpath(dest, dir))
        end
        for file in files
            cp(joinpath(root,file), joinpath(dest, file))
        end
        for dir in dirs
            dir_cp(joinpath(root, dir), joinpath(dest, dir))
        end
    end
end
