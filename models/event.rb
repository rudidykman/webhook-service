class Event < ActiveRecord::Base
  enum status: { pending: 'pending', success: 'success', failure: 'failure' }
end
