module FixtureHelpers
  def path_to_fixture(name)
    File.expand_path("../fixtures/#{name}", File.dirname(__FILE__))
  end

  RSpec.configuration.include FixtureHelpers
end
