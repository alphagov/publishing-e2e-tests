feature "Creating a new edition of a document with Whitehall", whitehall: true, government_frontend: true, finder_frontend: true do
  include WhitehallHelpers

  let(:title) { "Updating Whitehall Before #{SecureRandom.uuid}" }
  let(:updated_title) { "Updating Whitehall After #{SecureRandom.uuid}" }
  let(:change_note) { "Testing update behaviour" }

  scenario "Creating a new edition of a document with Whitehall" do
    given_i_have_a_published_document
    when_i_publish_a_new_edition_of_the_document
    then_i_can_view_the_updated_content_on_gov_uk
    and_it_is_updated_on_the_all_content_finder
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Whitehall" => %w[Editor],
    )
  end

  def given_i_have_a_published_document
    signin_to_signon if use_signon?
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

    page.find(:css, 'a[href="#full-history"]').click
    expect(page).to have_content("First published.")
    expect(page).to have_content(change_note)
  end

  def and_it_is_updated_on_the_all_content_finder
    finder_url = "#{Plek.new.website_root}/search/all?keywords=#{CGI.escape(updated_title)}"
    reload_url_until_match(finder_url, :has_text?, updated_title, reload_seconds: 120)
    visit finder_url

    expect_rendering_application("finder-frontend")
    # Session#find waits until an element appears
    # this seems to make a difference to the outcome
    # of this spec.
    find("a", text: updated_title)
    expect(page).to have_content(updated_title)
  end

  def create_new_edition
    click_link title
    click_button "Create new edition to edit"

    fill_in "Title", with: updated_title
    fill_in "Enter a public change note", with: change_note
    click_button("Save and continue")
    check "Test taxon"
    click_button("Save and review legacy tagging")
    click_button("Save")
    expect(page).to have_text("The associations have been saved")
  end
end
