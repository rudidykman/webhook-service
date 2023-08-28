require 'dotenv/load'
require 'json_schemer'
require 'pathname'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'

require_relative './lib/errors'
require_relative './services/notification_service'

def validate_request_body(body)
  schemer = JSONSchemer.schema(Pathname.new('./lib/event_schema.json'))
  validation_errors = schemer.validate(body).to_a
  raise InvalidRequestError, validation_errors[0] if validation_errors.length > 0
end

post '/notifications' do
  body = JSON.parse(request.body.read)
  validate_request_body(body)
  notification = NotificationService.create_and_send(body)
  json(notification)
rescue RequestError => error
  status(error.status)
  json(error.to_response_format)
rescue => error
  puts(error)
  status(500)
  json({ type: 'internal' })
end
