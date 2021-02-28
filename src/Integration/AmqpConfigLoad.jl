using YAML

struct FileNotFoundError <: Exception
    path::String
end

function getConfig(filepath::String, env::String)
    if ispath(filepath)
        config = YAML.load_file(filepath)[env]
        user = config["user"]  # default is usually "guest"
        password = config["password"]  # default is usually "guest"
        auth_params = compose_auth(user,password)
        host = config["host"]
        AmqpConnectionDef(host,auth_params)
    else
        throw(FileNotFoundError(filepath))
    end

end

function loadConfig(filepath::String = AMQP_CONN_FILE_PATH, env::String = AMQP_ENV)
    conn_def = getConfig(filepath, env)
    amqp_conn_define!(conn_def)
end
