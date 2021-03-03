function consumer_amqp_config!(chan, name)
    declare_queue!(chan, name)
end
