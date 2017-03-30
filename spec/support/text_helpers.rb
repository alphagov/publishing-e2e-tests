require "faker"

module TextHelpers
  def title_with_timestamp
    "#{Faker::Book.title} #{Time.now.to_i}"
  end

  def ignore_quotes(text)
    escaped = Regexp.escape(text).gsub(/["']/, %{["“”'‘’]})
    /#{escaped}/
  end

  RSpec.configuration.include TextHelpers
end
