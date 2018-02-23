module DraftContentHelpers
  def signin_to_draft_origin(user)
    already_at_signon = has_current_path?("#{signon_url}/users/signin")

    previous_url = current_url
    visit(Plek.find('draft-origin')) unless already_at_signon

    if has_current_path?("#{signon_url}/users/signin")
      signin_with_user(user)
    end

    store_cookies_for_retry_helpers

    visit(previous_url)
  end

  RSpec.configuration.include DraftContentHelpers
end
