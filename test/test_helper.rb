# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../test/dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
ActiveRecord::Base.connection.migration_context.migrate

require "rails/test_help"

# Load fixtures from the engine

if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

def create_file_blob(filename:, content_type:, metadata: nil)
  ActiveStorage::Blob.create_and_upload! io: file_fixture(filename).open, filename: filename, content_type: content_type, metadata: metadata
end
