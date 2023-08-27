class Event < ActiveRecord::Base
  enum status: { pending: 'pending', 'success', 'failure' }
end
