feature "Publishing content from Publisher to Government Frontend", publisher: true, government_frontend: true do
  include PublisherHelpers

  let(:title) { title_with_timestamp }
  let(:slug) { "help/" + slug_with_timestamp }

  scenario "Publishing a Help guide" do
    given_there_is_a_draft_help_guide
    and_i_publish_it
    then_i_can_view_it_on_gov_uk
    and_it_was_rendered_by_government_frontend
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
  end

  def and_it_was_rendered_by_government_frontend
    expect_rendering_application("government-frontend")
  end

  def wait_for_artefact_to_be_published
    url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(url)
  end
end
