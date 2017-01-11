module ReloadPageHelpers
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

  RSpec.configuration.include ReloadPageHelpers
end
