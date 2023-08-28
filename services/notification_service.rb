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
    notification
  end

  private

  def self.find_or_create_notification(event, application)
    notification = Notification.find_by(event_id: event['id'])
    return notification unless notification.nil?

    Notification.create!(event_id: event['id'], application_id: application.id, status: :pending)
    # Note: for this to be production ready, I would also add a step here to lock the notification in the DB
    # for the edge case where the same event is received multiple times very shortly after one another.
    # For this challenge I am ignoring that edge case.
  end

  def self.send_notification_to_svix(event, notification, application)
    svix = Svix::Client.new(ENV['SVIX_API_KEY'])
    # The event_id is also used as an idempotency key by Svix, see https://docs.svix.com/idempotency
    message = Svix::MessageIn.new({
      'event_type' => event['type'],
      'payload' => event,
      'event_id' => event['id']
    })
    svix.message.create(application.svix_application_id, message)
  rescue => error
    puts "Failed to create message on Svix for event #{event["id"]}: #{error}"
    notification.update!(status: :failed, failure_reason: error)
    raise error
  end
end
