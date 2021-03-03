function publisher_amqp_config!(chan, exchangename)
    vent_queue = exchangename * "-vent"
    declare_exchange!(chan, exchangename, EXCHANGE_TYPE_FANOUT)
    declare_queue!(chan, vent_queue)
    queue_bind(chan, vent_queue, exchangename, "*")
end

function dlq_amqp_config!(chan, name)
    declare_exchange!(chan, DLQ_EXCHANGE, EXCHANGE_TYPE_DIRECT)
    declare_queue!(chan, dlq)
    queue_bind(chan, dlq, DLQ_EXCHANGE, dlq)
end
