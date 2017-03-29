module ReloadPageHelpers
  class TimeoutError < RuntimeError; end

  def reload_page_while_failing
    attempt = 1
    begin
      yield
    rescue Capybara::ElementNotFound, RSpec::Expectations::ExpectationNotMetError => e
      raise e if attempt >= RSpec.configuration.reload_page_attempts
      attempt += 1
      visit(page.current_url)
      retry
    end
  end

  def reload_page_until(capybara_method, value, options = {})
    reload_options = {
      fail_reason: "#{page.current_url} didn't match #{value} for #{capybara_method.to_s}",
      reload_seconds: options[:reload_seconds] || nil,
      interval_seconds: options[:interval_seconds] || nil,
    }
    within_selector = options[:within]
    capybara_options = options.clone.tap do |o|
      o.delete(:reload_seconds)
      o.delete(:interval_seconds)
      o.delete(:within)
      o[:wait] = 0.5 unless o[:wait]
    end

    reload_page_while_false(reload_options) do
      if within_selector
        witin(within_selector, wait: capybara_options[:wait]) do
          page.public_send(capybara_method, value, capybara_options)
        end
      else
        page.public_send(capybara_method, value, capybara_options)
      end
    end
  end

  def reload_page_until_status_code(
    status_code,
    keep_retrying_while: [404],
    reload_seconds: nil,
    interval_seconds: nil
  )
    status_codes = Array(status_code)
    keep_retrying_while = Array(keep_retrying_while)

    reload_page_while_false(
      fail_reason: "#{page.current_url} was not returning #{status_codes.join(',')}",
      reload_seconds: reload_seconds,
      interval_seconds: interval_seconds,
    ) do
      unless (keep_retrying_while + status_codes).include?(page.status_code)
        raise "Aborting reloading #{page.current_url} as a #{page.status_code} was returned"
      end

      status_codes.include?(page.status_code)
    end
  end

  ## Inspired by (/copied from) https://github.com/natritmeyer/site_prism/blob/master/lib/site_prism/waiter.rb
  def reload_page_while_false(fail_reason: nil, reload_seconds: nil, interval_seconds: nil)
    start_time = Time.now
    wait_time_seconds = reload_seconds || RSpec.configuration.reload_page_wait_time
    interval_seconds = interval_seconds || 0.5
    loop do
      return true if yield
      break unless Time.now - start_time <= wait_time_seconds
      sleep(interval_seconds)
      visit(page.current_url)
    end
    fail_reason ||= "#{page.current_url} was not passing the expectation."
    raise TimeoutError, "After #{wait_time_seconds} seconds, #{fail_reason}"
  end

  RSpec.configuration.include ReloadPageHelpers
end
