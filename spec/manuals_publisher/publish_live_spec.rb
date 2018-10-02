feature "Publishing content on Manuals Publisher", manuals_publisher: true do
  include ManualsPublisherHelpers

  let(:title) { "Publishing a manual #{SecureRandom.uuid}" }

  scenario "Publishing a manual" do
    given_there_is_a_draft_manual_with_a_section
    when_i_publish_the_manual
    then_i_can_view_it_on_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Manuals Publisher" => %w[editor gds_editor],
    )
  end

  def given_there_is_a_draft_manual_with_a_section
    signin_to_signon if use_signon?
    create_draft_manual(title: title)
    create_manual_section
  end

  def when_i_publish_the_manual
    publish_manual
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)

    click_link "View on website"
    expect_rendering_application("manuals-frontend")
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
  end
end
