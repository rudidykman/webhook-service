# frozen_string_literal: true

require 'spec_helper'

describe ApplicationService do
  describe '.find_or_create_application' do
    let(:project) { 'test' }
    let(:svix_application_id) { 'app_123' }

    context 'when the application already exists' do
      let!(:existing_application) { Application.create!(project:, svix_application_id:) }

      it 'returns the existing application' do
        expect(ApplicationService).not_to receive(:create_application_on_svix)
        result = ApplicationService.find_or_create_application(project)
        expect(result).to eq(existing_application)
      end
    end

    context 'when the application does not yet exist' do
      let(:svix_application) { double('Svix::Application', id: svix_application_id) }

      before do
        allow(ApplicationService).to receive(:create_application_on_svix).and_return(svix_application)
      end

      it 'creates and returns a new application' do
        result = ApplicationService.find_or_create_application(project)
        expect(result).to be_instance_of(Application)
        expect(result.svix_application_id).to eq(svix_application_id)
      end
    end
  end
end
