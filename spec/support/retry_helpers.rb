require "httparty"
require_relative "../../lib/retry_while_false"

module RetryHelpers
  class TimeoutError < RuntimeError; end

  def reload_url_until_match(url, capybara_method, value, options = {})
    reload_options = {
      fail_reason: "#{url} didn't match #{value} for #{capybara_method}",
      reload_seconds: options[:reload_seconds] || nil,
      interval_seconds: options[:interval_seconds] || nil,
    }

    status_codes = Array(options[:status_codes] || options[:status_code] || 200)
    within_selector = options[:within]
    capybara_options = options.clone.tap do |o|
      o.delete(:status_code)
      o.delete(:status_codes)
      o.delete(:reload_seconds)
      o.delete(:interval_seconds)
      o.delete(:within)
      o[:wait] = 0.5 unless o[:wait]
    end

    code = HTTParty.head(url).code
    unless status_codes.include?(code)
      raise "#{url} returned a status code of #{code}"
    end

    session = Capybara::Session.new(Capybara.default_driver)

    retry_while_false(reload_options) do
      session.visit(url)
      if within_selector
        session.witin(within_selector, wait: capybara_options[:wait]) do
          session.public_send(capybara_method, value, capybara_options)
        end
      else
        session.public_send(capybara_method, value, capybara_options)
      end
    end
  end

  def reload_url_until_status_code(
    url,
    status_code,
    keep_retrying_while: [404],
    reload_seconds: nil,
    interval_seconds: nil
  )
    status_codes = Array(status_code)
    keep_retrying_while = Array(keep_retrying_while)
    reload_options = {
      fail_reason: "#{url} was not returning #{status_codes.join(',')}",
      reload_seconds: reload_seconds,
      interval_seconds: interval_seconds,
    }

    retry_while_false(reload_options) do
      code = HTTParty.head(url, follow_redirects: false).code
      unless (keep_retrying_while + status_codes).include?(code)
        raise "Aborting reloading #{url} as a #{code} was returned"
      end

      status_codes.include?(code)
    end
  end

  def retry_while_false(fail_reason: nil, reload_seconds: nil, interval_seconds: nil, &block)
    reload_seconds = reload_seconds || RSpec.configuration.reload_page_wait_time
    interval_seconds = interval_seconds || 0.5
    success = RetryWhileFalse.(reload_seconds: reload_seconds, interval_seconds: interval_seconds, &block)
    fail_reason ||= "the expectation was not met"
    raise TimeoutError, "After #{reload_seconds} seconds, #{fail_reason}" unless success
  end

  RSpec.configuration.include RetryHelpers
end
