feature "Publishing content on Manuals Publisher", manuals_publisher: true do
  include ManualsHelpers

  let(:title) { title_with_timestamp }

  scenario "Publishing a manual" do
    given_there_is_a_draft_manual_with_a_section
    when_i_publish_the_manual
    then_i_can_view_it_on_gov_uk
  end

  def given_there_is_a_draft_manual_with_a_section
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
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
    expect_rendering_application("manuals-frontend")
  end
end
