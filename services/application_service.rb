# frozen_string_literal: true

require 'svix'

require_relative '../models/application'

module ApplicationService
  def self.find_or_create_application(project)
    application = Application.find_by(project:)
    return application unless application.nil?

    svix_application = create_application_on_svix(project)
    Application.create!(svix_application_id: svix_application.id, project:)
  end

  private_class_method def self.create_application_on_svix(project)
    svix = Svix::Client.new(ENV['SVIX_API_KEY'])
    svix.application.create(Svix::ApplicationIn.new({ 'name' => project }))
  end
end
