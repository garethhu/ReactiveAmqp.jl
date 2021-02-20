function consumer_amqp_config!(chan, name, dlq)
    declare_queue!(chan, name)
    declare_exchange!(chan, DLQ_EXCHANGE, EXCHANGE_TYPE_DIRECT)
    declare_queue!(chan, dlq)
    queue_bind(chan, dlq, DLQ_EXCHANGE, dlq)
end
