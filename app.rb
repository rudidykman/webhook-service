require 'dotenv/load'
require 'json_schemer'
require 'pathname'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'

require_relative './lib/errors'
require_relative './services/event_service'

def validate_request_body(body)
  event_schemer = JSONSchemer.schema(Pathname.new('./lib/event_schema.json'))
  validation_errors = event_schemer.validate(body).to_a
  raise InvalidRequestError, validation_errors[0] if validation_errors.length > 0
end

post '/events' do
  body = JSON.parse(request.body.read)
  validate_request_body(body)
  EventService.create_and_send(body)
rescue RequestError => error
  status(error.status)
  json(error.to_response_format)
rescue => error
  puts(error)
  status(500)
  json({ type: 'internal' })
end
