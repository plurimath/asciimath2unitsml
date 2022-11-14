require "simplecov"

SimpleCov.profiles.define "gem" do
  add_filter "/spec/"
  add_filter "/autotest/"
  add_group "Libraries", "/lib/"
end
SimpleCov.start "gem"

require "asciimath2unitsml"
require "rspec/matchers"
require "equivalent-xml/rspec_matchers"
require "rexml/document"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def xmlpp(xml)
  Nokogiri::XML(xml).to_xml(indent: 2, encoding: "UTF-8")
end
