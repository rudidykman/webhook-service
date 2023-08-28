require 'svix'

require_relative './application_service'
require_relative '../models/notification'
require_relative '../lib/errors'

module NotificationService
  def self.create_and_send(event)
    application = ApplicationService.find_or_create_application(event['project'])
    notification = find_or_create_notification(event, application)
    raise ConflictError, "Notification for event #{notification.event_id} has already been sent to Svix." if notification.submitted?

    svix_message = send_notification_to_svix(event, notification, application)
    notification.update!(status: :submitted, svix_message_id: svix_message.id, failure_reason: nil)
  end

  private

  def self.find_or_create_notification(event, application)
    notification = Notification.find_by(event_id: event['id'])
    return notification unless notification.nil?
    # TODO: what do we do if we find an existing pending notification here?

    Notification.create!(event_id: event['id'], application_id: application.id, status: :pending)
  end

  def self.send_notification_to_svix(event, notification, application)
    svix = Svix::Client.new(ENV['SVIX_API_KEY'])
    message = Svix::MessageIn.new({
      'event_type' => event['type'],
      'payload' => event['data'],
      'event_id' => event['id']
    })
    svix.message.create(application.svix_application_id, message)
  rescue => error
    puts "Failed to create message on Svix for event #{event["id"]}: #{error}"
    notification.update!(status: :failed, failure_reason: error)
  end
end
