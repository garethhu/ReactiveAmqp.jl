using AMQPClient

struct ExchangeDeclarationError <: Exception
    exchange_name::String
end

function declare_exchange!(chan, exchange_name, type)
    success = exchange_declare(chan, exchange_name, type)
    success || throw(ExchangeDeclarationError(exchange_name))
    exchange_name
end
