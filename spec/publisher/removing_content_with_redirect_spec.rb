feature "Removing content by redirecting it from Publisher", publisher: true do
  include PublisherHelpers

  let(:title) { unique_title }
  let(:slug) { "removing-content-with-redirect-publisher-#{SecureRandom.uuid}" }
  let(:redirect_url) { "https://www.gov.uk/help" }

  scenario "Unpublishing an artefact" do
    given_there_is_a_published_artefact_with_subpages
    when_i_remove_the_published_artefact_with_a_redirect_to_help
    then_visiting_the_artefact_redirects_to_help
    and_visiting_a_subpage_redirects_to_help_with_slug
  end

  private

  def signin_to_signon
    @user = signin_with_next_user(
      "Publisher" => ["skip_review"],
    )
  end

  def given_there_is_a_published_artefact_with_subpages
    signin_to_signon if use_signon?
    create_publisher_artefact(slug: slug, title: title, format: "Guide")
    add_part_to_artefact(title: unique_title)
    @subpart_slug = add_part_to_artefact(title: unique_title)

    publish_artefact
    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end

  def when_i_remove_the_published_artefact_with_a_redirect_to_help
    switch_to_tab "Unpublish"

    fill_in "redirect_url", with: redirect_url

    page.accept_confirm do
      click_button "Unpublish"
    end

    expect(page).to have_content("Content unpublished")
  end

  def then_visiting_the_artefact_redirects_to_help
    reload_url_until_status_code(@published_url, 301, keep_retrying_while: [200])

    visit(@published_url)

    expect_url_matches_live_gov_uk
    expect(page).to have_content("Help")
    expect(current_url).to end_with("gov.uk/help")
  end

  def and_visiting_a_subpage_redirects_to_help_with_slug
    reload_url_until_status_code(subpage_url, 301, keep_retrying_while: [200])

    visit(subpage_url)
    expect(current_url).to end_with("gov.uk/help/#{@subpart_slug}")
  end

  def subpage_url
    [@published_url, @subpart_slug].join("/")
  end
end
