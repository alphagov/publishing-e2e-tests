feature "Publishing a document with Whitehall", new: true, whitehall: true, government_frontend: true do
  include WhitehallHelpers

  let(:title) { "Publishing Whitehall #{SecureRandom.uuid}" }

  scenario "Publishing a document with Whitehall" do
    given_i_have_a_draft_document
    when_i_publish_it
    then_i_can_view_it_on_gov_uk
    and_it_is_displayed_on_the_publication_finder
  end

  def given_i_have_a_draft_document
    visit(Plek.find("whitehall-admin") + "/government/admin/consultations/new")

    fill_in "Title", with: title
    fill_in "Summary", with: sentence
    fill_in "Body", with: paragraph_with_timestamp
    fill_in_opening_date(Date.today)
    fill_in_closing_date(Date.today.next_year)
    select_from_chosen "Test Policy Area", id: "edition_topic_ids"

    click_button("Save")
    expect(page).to have_text("The document has been saved")
  end

  def when_i_publish_it
    click_link("Force publish")
    fill_in "Reason for force publishing", with: "End to end test"
    click_button("Force publish")

    expect(page).to have_text("has been published")
  end

  def then_i_can_view_it_on_gov_uk
    click_link title
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)

    switch_to_window(window_opened_by { click_link("View on website") })

    expect_rendering_application("government-frontend")
    expect_url_matches_live_gov_uk
    expect(page).to have_content(title)
  end

  def and_it_is_displayed_on_the_publication_finder
    publication_finder = find('a', text: "Publications", match: :first)[:href]
    reload_url_until_match(publication_finder, :has_text?, title)
    visit(publication_finder)

    expect_rendering_application("whitehall")
    expect(page).to have_content(title)
  end
end
