require 'spec_helper'

describe ApplicationService do
  describe '.find_or_create_application' do
    let(:project) { 'test' }
    let(:svix_application_id) { 'app_123' }

    context 'when the application already exists' do
      it 'returns the existing application' do
        existing_application = Application.create(svix_application_id: svix_application_id, project: project)

        result = ApplicationService.find_or_create_application(project)
        expect(result).to eq(existing_application)
      end
    end

    context 'when the application does not yet exist' do
      it 'creates and returns a new application' do
        allow(ApplicationService).to receive(:create_application_on_svix).and_return(
          double('Svix::Application', id: svix_application_id)
        )

        result = ApplicationService.find_or_create_application(project)
        expect(result.project).to eq(project)
        expect(result.svix_application_id).to eq(svix_application_id)
      end
    end
  end
end
