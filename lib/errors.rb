# frozen_string_literal: true

class RequestError < StandardError; end

class InvalidRequestError < RequestError
  def initialize(validation_error)
    @message = validation_error['error']
    super(@message)
  end

  def status
    400
  end

  def to_response_format
    {
      type: 'invalid_request',
      message: @message
    }
  end
end
