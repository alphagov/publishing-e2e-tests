feature "Creating a draft on Manuals Publisher", manuals_publisher: true do
  include ManualsPublisherHelpers

  let(:title) { "Creating a draft manual #{SecureRandom.uuid}" }

  scenario "Creating a draft manual" do
    when_i_create_a_new_manual
    then_i_can_preview_it_on_draft_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Manuals Publisher" => %w[editor gds_editor],
      "Content Preview" => [],
    )
  end

  def when_i_create_a_new_manual
    signin_to_signon if use_signon?
    create_draft_manual(title: title)
  end

  def then_i_can_preview_it_on_draft_gov_uk
    signin_to_draft_origin(@user) if use_signon?

    url = find_link("Preview draft")[:href]
    reload_url_until_status_code(url, 200)

    click_link "Preview draft"
    expect_rendering_application("manuals-frontend")
    expect(page).to have_content(title)
    expect_url_matches_draft_gov_uk
  end
end
