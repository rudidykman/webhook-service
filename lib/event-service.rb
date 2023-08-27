module EventService
  def self.create_and_send(network_event)
    application find_or_create_application(network_event['project'])
    event = find_or_create_event(network_event)

    # TODO: raise conflict error if event has been sent to Svix

    send_event_to_svix(event, application)
  end

  private

  def find_or_create_application(project)
    # TODO
  end

  def find_or_create_event(network_event)
    # TODO
  end

  def send_event_to_svix(event, application)
    # TODO
  end
end
