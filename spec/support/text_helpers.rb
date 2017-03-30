require "faker"

module TextHelpers
  def title_with_timestamp
    "#{Faker::Book.title} #{Time.now.to_i}"
  end

  RSpec.configuration.include TextHelpers
end
