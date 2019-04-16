feature "Publishing a document with Whitehall", whitehall: true, government_frontend: true, finder_frontend: true do
  include WhitehallHelpers

  let(:title) { "Publishing Whitehall #{SecureRandom.uuid}" }

  scenario "Publishing a document with Whitehall" do
    given_i_have_a_draft_document
    when_i_publish_it
    then_i_can_view_it_on_gov_uk
    and_it_is_displayed_on_the_publication_finder
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Whitehall" => %w[Editor],
    )
  end

  def given_i_have_a_draft_document
    signin_to_signon if use_signon?
    create_consultation(title: title)
  end

  def when_i_publish_it
    force_publish_document
  end

  def then_i_can_view_it_on_gov_uk
    click_link title
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)

    switch_to_window(window_opened_by { click_link("View on website") })

    expect_rendering_application("government-frontend")
    expect_url_matches_live_gov_uk
    expect(page).to have_content(title)
    expect(page).to have_content("Test taxon")
  end

  def and_it_is_displayed_on_the_publication_finder
    publication_finder = find('a', text: "Publications", match: :first)[:href]
    reload_url_until_match(publication_finder, :has_text?, title)
    visit(publication_finder)

    # This test is pretty flakey, with the 'page.find' below often
    # failing.  I don't really understand why, but reloading the page
    # makes it work much more reliably..
    visit(publication_finder)

    expect_rendering_application("finder-frontend")
    # Session#find waits until an element is visible
    # this appears to influence the outcome of this spec.
    page.find("a", text: title)
    expect(page).to have_content(title)
  end
end
