feature "Creating a draft on Manuals Publisher", manuals_publisher: true do
  include ManualsPublisherHelpers

  let(:title) { "Creating a draft manual #{SecureRandom.uuid}" }

  scenario "Creating a draft manual" do
    when_i_create_a_new_manual
    then_i_can_preview_it_on_draft_gov_uk
  end

  def when_i_create_a_new_manual
    create_draft_manual(title: title)
  end

  def then_i_can_preview_it_on_draft_gov_uk
    url = find_link("Preview draft")[:href]
    reload_url_until_status_code(url, 200)

    click_link "Preview draft"
    expect_rendering_application("manuals-frontend")
    expect(page).to have_content(title)
    expect_url_matches_draft_gov_uk
  end
end
