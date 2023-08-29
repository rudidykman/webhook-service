# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'database_cleaner/active_record'

require_relative '../app'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Migration.maintain_test_schema!
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
