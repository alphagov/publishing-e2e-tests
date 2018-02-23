feature "Unpublishing a document by consolidating into another page on Whitehall", whitehall: true, government_frontend: true do
  include WhitehallHelpers

  let(:title) { "Unpublishing Whitehall #{SecureRandom.uuid}" }
  let(:redirection_destination) { Plek.new.website_root + "/help" }

  scenario "Unpublishing a document on Whitehall by consolidating into another page " do
    given_i_have_a_published_document
    when_i_unpublish_it_and_redirect_to_another_page
    then_i_am_redirected_when_i_visit_the_page_on_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Whitehall" => ["Editor"],
    )
  end

  def given_i_have_a_published_document
    signin_to_signon if use_signon?
    create_consultation(title: title)
    force_publish_document
    click_link title
    @published_url = find_link("View on website")[:href]
    reload_url_until_status_code(@published_url, 200)
  end

  def when_i_unpublish_it_and_redirect_to_another_page
    click_link "Withdraw or unpublish"
    choose "Unpublish: consolidated into another GOV.UK page"
    fill_in "consolidated_alternative_url", with: redirection_destination
    click_button "Unpublish"
    expect(page).to have_text("This document has been unpublished")
  end

  def then_i_am_redirected_when_i_visit_the_page_on_gov_uk
    reload_url_until_status_code(@published_url, 301, keep_retrying_while: [200, 404])

    visit @published_url
    expect(current_url).to eq(redirection_destination)
  end
end
