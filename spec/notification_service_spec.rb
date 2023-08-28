require 'spec_helper'

describe NotificationService do
  describe '.create_and_send' do
    let(:project) { 'test' }
    let(:event) do
      {
        'id' => 'evt_123',
        'type' => 'subscription.updated',
        'data' => { 'key' => 'value' },
        'project' => project
      }
    end
    let(:application) { Application.create!(svix_application_id: 'app_123', project: project) }
    let(:svix_message) { double('Svix::Message', id: 'msg_123') }

    before do
      allow(ApplicationService).to receive(:find_or_create_application).and_return(application)
    end

    context 'when a notification does not exist for the event' do
      it 'creates and sends the notification to Svix' do
        expect(NotificationService).to receive(:send_notification_to_svix).and_return(svix_message)

        NotificationService.create_and_send(event)

        notification = Notification.find_by(event_id: event['id'])
        expect(notification.status).to eq('submitted')
        expect(notification.svix_message_id).to eq(svix_message.id)
      end
    end

    context 'when a notification already exists for the event' do
      context 'when the existing notification status is failed' do
        it 'creates and sends the notification to Svix' do
          Notification.create!(event_id: event['id'], application_id: application.id, status: :failed, failure_reason: 'test')
          
          expect(NotificationService).to receive(:send_notification_to_svix).and_return(svix_message)
          NotificationService.create_and_send(event)

          notification = Notification.find_by(event_id: event['id'])
          expect(notification.status).to eq('submitted')
          expect(notification.svix_message_id).to eq(svix_message.id)
        end
      end

      context 'when the existing notification status is submitted' do
        it 'raises a ConflictError' do
          Notification.create!(event_id: event['id'], application_id: application.id, status: :submitted, svix_message_id: svix_message.id)

          expect(NotificationService).not_to receive(:send_notification_to_svix)

          expect {
            NotificationService.create_and_send(event)
          }.to raise_error(ConflictError, /has already been sent to Svix/)
        end
      end
    end

    context 'when there is an error sending to Svix' do
      it 'updates the notification with failure status and reason' do
        error_message = 'Test error'
        allow_any_instance_of(Svix::Client).to receive(:message).and_raise(error_message)

        expect {
          NotificationService.create_and_send(event)
        }.to raise_error(StandardError, error_message)
        
        notification = Notification.find_by(event_id: event['id'])
        expect(notification.status).to eq('failed')
        expect(notification.failure_reason).to eq(error_message)
      end
    end
  end
end
