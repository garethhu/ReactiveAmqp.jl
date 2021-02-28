const AMQP_ENV_KEY = "AMQP_ENV"
const AMQP_CF_FILEPATH_KEY = "AMQP_CF_FILEPATH_KEY"

const PKG_ROOT = dirname(dirname(@__DIR__))
const PROJ_ROOT = pwd()
const AMQP_ENV = haskey(ENV, AMQP_ENV_KEY) ? ENV[AMQP_ENV_KEY] : "dev"

const NEW_APP_PATH = joinpath("files", "new_app")

const AMQP_PATH = "amqp"

const AMQP_CONNECTION_FILE = "connection.yaml"

const AMQP_CONN_FILE_PATH =  haskey(ENV, AMQP_CF_FILEPATH_KEY) ? ENV[AMQP_CF_FILEPATH_KEY] : joinpath(PROJ_ROOT, AMQP_PATH, AMQP_CONNECTION_FILE)
