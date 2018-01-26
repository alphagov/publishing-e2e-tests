feature "Creating a new edition of a document with Whitehall", new: true, whitehall: true, government_frontend: true do
  include WhitehallHelpers

  let(:title) { "Updating Whitehall Before #{SecureRandom.uuid}" }
  let(:updated_title) { "Updating Whitehall After #{SecureRandom.uuid}" }

  scenario "Creating a new edition of a document with Whitehall" do
    given_i_have_a_published_document
    when_i_publish_a_new_edition_of_the_document
    then_i_can_view_the_updated_content_on_gov_uk
    and_it_is_updated_on_the_publication_finder
  end

  def given_i_have_a_published_document
    create_consultation(title: title)
    force_publish_document
  end

  def when_i_publish_a_new_edition_of_the_document
    create_new_edition
    force_publish_document
  end

  def then_i_can_view_the_updated_content_on_gov_uk
    click_link updated_title
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, updated_title)

    switch_to_window(window_opened_by { click_link("View on website") })

    expect_rendering_application("government-frontend")
    expect_url_matches_live_gov_uk
    expect(page).to have_content(updated_title)
  end

  def and_it_is_updated_on_the_publication_finder
    publication_finder = find('a', text: "Publications", match: :first)[:href]
    reload_url_until_match(publication_finder, :has_text?, updated_title)
    visit(publication_finder)

    expect_rendering_application("whitehall")
    expect(page).to have_content(updated_title)
  end

  def create_new_edition
    click_link title
    click_button "Create new edition to edit"

    fill_in "Title", with: updated_title
    fill_in "Public change note", with: "Testing update behaviour"
    click_button("Save")

    expect(page).to have_text("The document has been saved")
  end
end
