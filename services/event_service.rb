require 'svix'

require_relative './application_service'
require_relative '../models/event'
require_relative '../lib/errors'

module EventService
  def self.create_and_send(network_event)
    application = ApplicationService.find_or_create_application(network_event['project'])
    event = find_or_create_event(network_event, application)
    byebug
    raise ConflictError, "Event #{event.external_id} has already been sent to Svix." if event.status == 'success'

    send_event_to_svix(network_event, event, application)
    event.update!(status: :success)
  end

  private

  def self.find_or_create_event(network_event, application)
    event = Event.find_by(external_id: network_event['id'])
    return event unless event.nil?
    # TODO: what do we do if we find an existing pending event here?

    Event.create!(external_id: network_event['id'], application_id: application.id, status: :pending)
  end

  def self.send_event_to_svix(network_event, event, application)
    puts "Creating Svix message for event #{event.external_id}..."
    svix = Svix::Client.new(ENV['SVIX_API_KEY'])
    message = Svix::MessageIn.new({
      'event_type' => network_event['type'],
      'payload' => network_event['data'],
      'event_id' => network_event['id']
    })
    svix.message.create(application.external_id, message)
  rescue => error
    event.update!(status: :failure, failure_reason: error)
  end
end
