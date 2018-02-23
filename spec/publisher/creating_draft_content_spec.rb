feature "Creating draft content on Publisher", publisher: true, frontend: true do
  include PublisherHelpers

  let(:title) { unique_title }
  let(:slug) { "creating-draft-publisher-content-#{SecureRandom.uuid}" }

  scenario "Creating a draft artefact" do
    when_i_create_a_new_artefact
    then_i_can_preview_it_on_draft_gov_uk_and_was_rendered_by_frontend
  end

  private

  def signin_to_signon
    @user = signin_with_next_user(
      "Publisher" => ["skip_review"],
      "Content Preview" => [],
    )
  end

  def when_i_create_a_new_artefact
    signin_to_signon if use_signon?
    create_publisher_artefact(slug: slug, title: title)
  end

  def then_i_can_preview_it_on_draft_gov_uk_and_was_rendered_by_frontend
    wait_for_draft_to_be_published

    click_link("Preview")
    expect_rendering_application("frontend")
    expect(page).to have_content(title)
    expect_url_matches_draft_gov_uk
  end

  def wait_for_draft_to_be_published
    signin_to_draft_origin(@user) if use_signon?
    draft_url = find_link("Preview")[:href]
    wait_for_artefact_to_be_viewable(draft_url)
  end
end
