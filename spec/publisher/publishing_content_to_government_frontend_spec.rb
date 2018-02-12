feature "Publishing content from Publisher to Government Frontend", finder_frontend: true, publisher: true, government_frontend: true do
  include PublisherHelpers

  let(:title) { unique_title }
  let(:slug) { "help/publishing-content-publisher-to-government-frontend-#{SecureRandom.uuid}" }

  scenario "Publishing a Help guide" do
    given_there_is_a_draft_help_guide
    and_i_publish_it
    then_i_can_view_it_on_gov_uk
    and_i_can_view_it_on_finder
  end

  private

  def given_there_is_a_draft_help_guide
    create_publisher_artefact(slug: slug, title: title, format: "Help page")
  end

  def and_i_publish_it
    publish_artefact
  end

  def then_i_can_view_it_on_gov_uk
    wait_for_artefact_to_be_published

    click_link("View this on the GOV.UK website")
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
    expect_rendering_application("government-frontend")
  end

  def and_i_can_view_it_on_finder
    fill_in "Search", with: title
    click_button "Search"

    expect_rendering_application("finder-frontend")
    expect(page).to have_content(title)
  end

  def wait_for_artefact_to_be_published
    url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(url)
  end
end
