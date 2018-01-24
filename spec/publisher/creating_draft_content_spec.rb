feature "Creating draft content on Publisher", publisher: true, frontend: true do
  include PublisherHelpers

  let(:title) { unique_title }
  let(:slug) { "creating-draft-publisher-content-#{SecureRandom.uuid}" }

  scenario "Creating a draft artefact" do
    when_i_create_a_new_artefact
    then_i_can_preview_it_on_draft_gov_uk_and_was_rendered_by_frontend
  end

  private

  def when_i_create_a_new_artefact
    create_publisher_artefact(slug: slug, title: title)
  end

  def then_i_can_preview_it_on_draft_gov_uk_and_was_rendered_by_frontend
    wait_for_draft_to_be_published

    click_link("Preview")
    expect(page).to have_content(title)
    expect_url_matches_draft_gov_uk
    expect_rendering_application("frontend")
  end

  def wait_for_draft_to_be_published
    draft_url = find_link("Preview")[:href]
    wait_for_artefact_to_be_viewable(draft_url)
  end
end
