class RetryWhileFalse
  ## Inspired by (/copied from) https://github.com/natritmeyer/site_prism/blob/master/lib/site_prism/waiter.rb
  def self.call(reload_seconds: 30, interval_seconds: nil)
    start_time = Time.now.utc
    interval_seconds = interval_seconds || 0.5
    loop do
      return true if yield
      break unless Time.now.utc - start_time <= reload_seconds
      sleep(interval_seconds)
    end
    false
  end
end
