using YAML

struct FileNotFoundError <: Exception
    path::String
end

function getConfig(filepath::String)
    if ispath(filepath)
        config = YAML.load_file(filepath)[AMQP_ENV]
        user = config["user"]  # default is usually "guest"
        password = config["password"]  # default is usually "guest"
        auth_params = compose_auth(user,password)
        host = config["host"]
        AmqpConnectionDef(host,auth_params)
    else
        throw(FileNotFoundError(filepath))
    end

end

function loadConfig()
    conn_def = getConfig(AMQP_CONN_FILE_PATH)
    amqp_conn_define!(conn_def)
end
