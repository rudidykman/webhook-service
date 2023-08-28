require 'spec_helper'
require 'rack/test'

describe 'app.rb' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'POST /notifications' do
    let(:valid_request_body) do 
      {
        object: 'event',
        id: 'evt_123',
        data: {},
        datacontenttype: 'application/json',
        project: 'test',
        source: 'https://api.gigs.com',
        specversion: '1.0',
        time: '2023-03-24T15:50:41Z',
        type: 'subscription.updated',
        version: '2023-01-30'
      }.to_json
    end

    context 'when request body is valid' do
      let(:notification) { Notification.new(status: 'submitted') }

      it 'returns a successful response' do
        allow(NotificationService).to receive(:create_and_send).and_return(notification)
        post '/notifications', valid_request_body

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(JSON.parse(last_response.body)).to include('status' => 'submitted')
      end

      context 'when there is a conflict error' do
        it 'returns a validation error response' do
          allow(NotificationService).to receive(:create_and_send).and_raise(ConflictError, 'Test conflict error')
          post '/notifications', valid_request_body
  
          expect(last_response.status).to eq(409)
          expect(last_response.content_type).to eq('application/json')
          expect(JSON.parse(last_response.body)).to include('type' => 'conflict')
        end
      end
    end

    context 'when request body is invalid' do
      let(:invalid_request_body) { { valide: false }.to_json }

      it 'returns a validation error response' do
        post '/notifications', invalid_request_body

        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(JSON.parse(last_response.body)).to include('type' => 'invalid_request')
      end
    end

    context 'when there is an internal server error' do
      it 'returns an internal server error response' do
        allow(NotificationService).to receive(:create_and_send).and_raise('Internal Server Error')
        post '/notifications', valid_request_body

        expect(last_response.status).to eq(500)
        expect(last_response.content_type).to eq('application/json')
        expect(JSON.parse(last_response.body)).to include('type' => 'internal')
      end
    end
  end
end
