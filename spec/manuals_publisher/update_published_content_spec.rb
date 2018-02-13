feature "Updating content on Manuals Publisher", manuals_publisher: true do
  include ManualsPublisherHelpers

  let(:title) { "Updating a manual #{SecureRandom.uuid}" }
  let(:section_title) { unique_title }
  let(:change_note) { sentence }

  scenario "Update a published manual with a new section" do
    given_there_is_a_published_manual_with_a_section
    when_i_add_a_new_section_with_a_change_note
    and_i_publish_the_manual
    then_the_manual_contents_page_links_to_the_new_section_on_gov_uk
    and_the_update_log_has_the_change_note
  end

  def given_there_is_a_published_manual_with_a_section
    create_draft_manual(title: title)
    create_manual_section
    publish_manual
  end

  def when_i_add_a_new_section_with_a_change_note
    create_manual_section(title: section_title, change_note: change_note)
  end

  def and_i_publish_the_manual
    publish_manual
  end

  def then_the_manual_contents_page_links_to_the_new_section_on_gov_uk
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, section_title)

    click_link "View on website"
    expect_rendering_application("manuals-frontend")
    expect(page).to have_content(title)
    expect(page).to have_content(section_title)
    expect_url_matches_live_gov_uk
  end

  def and_the_update_log_has_the_change_note
    click_link "see all updates"

    expect(page).to have_content(change_note)
  end
end
