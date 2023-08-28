# == Schema Information
#
# Table name: applications
#
#  id                  :integer          not null, primary key
#  svix_application_id :string           not null
#  project             :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Application < ActiveRecord::Base
end
