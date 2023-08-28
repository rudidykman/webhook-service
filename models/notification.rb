# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  event_id        :string           not null
#  svix_message_id :string
#  application_id  :integer
#  status          :string           not null
#  failure_reason  :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Notification < ActiveRecord::Base
  enum status: { pending: 'pending', submitted: 'submitted', failed: 'failed' }
end
