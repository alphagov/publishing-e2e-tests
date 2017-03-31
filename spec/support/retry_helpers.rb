require "httparty"

module RetryHelpers
  class TimeoutError < RuntimeError; end

  def reload_url_until_match(url, capybara_method, value, options = {})
    reload_options = {
      fail_reason: "#{url} didn't match #{value} for #{capybara_method.to_s}",
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
    unless (status_codes).include?(code)
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
    keep_retrying_while: [404, 503],
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
      code = HTTParty.head(url).code
      unless (keep_retrying_while + status_codes).include?(code)
        raise "Aborting reloading #{url} as a #{code} was returned"
      end

      status_codes.include?(code)
    end
  end

  ## Inspired by (/copied from) https://github.com/natritmeyer/site_prism/blob/master/lib/site_prism/waiter.rb
  def retry_while_false(fail_reason: nil, reload_seconds: nil, interval_seconds: nil)
    start_time = Time.now
    wait_time_seconds = reload_seconds || RSpec.configuration.reload_page_wait_time
    interval_seconds = interval_seconds || 0.5
    loop do
      return true if yield
      break unless Time.now - start_time <= wait_time_seconds
      sleep(interval_seconds)
    end
    fail_reason ||= "the expectation was not met"
    raise TimeoutError, "After #{wait_time_seconds} seconds, #{fail_reason}"
  end

  RSpec.configuration.include RetryHelpers
end
