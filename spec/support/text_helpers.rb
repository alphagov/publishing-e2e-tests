require "faker"

module TextHelpers
  def unique_title
    # As quotes are changed to curly quotes by govspeak they are a pain to
    # match, so we strip them here
    "#{Faker::Book.title.delete("'")} #{SecureRandom.uuid}"
  end

  def slug_with_timestamp
    "#{Faker::Internet.slug(nil, '-')}-#{Time.now.to_i}"
  end

  def paragraph_with_timestamp
    "#{Faker::Lorem.paragraph} #{Time.now.to_i}"
  end

  def sentence
    Faker::Lorem.sentence
  end

  def ignore_quotes_regex(text)
    escaped = Regexp.escape(text).gsub(/["']/, %{["“”'‘’]})
    /#{escaped}/
  end

  RSpec.configuration.include TextHelpers
end
