# frozen_string_literal: true

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
  belongs_to :application
  enum status: { pending: 'pending', submitted: 'submitted', failed: 'failed' }
  validates :application_id, presence: true
  validates :event_id, presence: true
  validates :status, presence: true
  validate :failure_reason_only_for_failed_status
  validate :svix_message_id_only_for_submitted_status

  private

  def failure_reason_only_for_failed_status
    return unless failure_reason.present? && !failed?

    errors.add(:failure_reason, 'can only be specified for failed status')
  end

  def svix_message_id_only_for_submitted_status
    return unless svix_message_id.present? && !submitted?

    errors.add(:svix_message_id, 'can only be specified for submitted status')
  end
end
