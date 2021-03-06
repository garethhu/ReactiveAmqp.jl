include("constants.jl")

function init_config!()
    from_location = joinpath(PKG_ROOT, NEW_APP_PATH)
    dir_cp(from_location, PROJ_ROOT)
end

function dir_cp(src::String, dest::String)
    items = readdir(src)
    dirs = filter(item -> isdir(joinpath(src,item)), items)
    files = filter(item -> isfile(joinpath(src,item)), items)
    for dir in dirs
        newpath = joinpath(dest, dir)
        if !isdir(newpath)
            mkdir(newpath)
        end
    end
    for file in files
        destination = joinpath(dest, file)
        if !isfile(destination)
            cp(joinpath(src,file), destination)
        end
    end
    for dir in dirs
        dir_cp(joinpath(src, dir), joinpath(dest, dir))
    end
end
