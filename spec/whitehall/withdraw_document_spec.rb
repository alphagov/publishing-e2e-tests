feature "Withdraw a document with Whitehall", whitehall: true, government_frontend: true do
  include WhitehallHelpers

  let(:title) { "Withdraw Whitehall #{SecureRandom.uuid}" }
  let(:withdrawal_explanation) { "Testing withdrawing a document" }

  scenario "Withdrawing a document with Whitehall" do
    given_i_have_a_published_document
    when_i_withdraw_it
    then_i_can_view_the_withdrawal_notice_on_gov_uk
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
  end

  def when_i_withdraw_it
    click_link "Withdraw or unpublish"
    choose "Withdraw: no longer current government policy/activity"
    fill_in "Public explanation (this is shown on the live site)", with: withdrawal_explanation
    click_button "Withdraw"
    expect(page).to have_content("This document has been marked as withdrawn")
  end

  def then_i_can_view_the_withdrawal_notice_on_gov_uk
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, withdrawal_explanation)

    switch_to_window(window_opened_by { click_link("View on website") })

    expect_rendering_application("government-frontend")
    expect_url_matches_live_gov_uk
    expect(page).to have_content(withdrawal_explanation)
    expect(page).to have_content("This consultation was withdrawn")
  end
end
