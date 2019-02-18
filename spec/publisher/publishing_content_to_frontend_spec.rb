feature "Publishing content from Publisher to Frontend", publisher: true, frontend: true, flaky: true do
  include PublisherHelpers

  let(:title) { unique_title }
  let(:slug) { "publishing-content-publisher-to-frontend-#{SecureRandom.uuid}" }
  let(:subpart_title) { unique_title }

  scenario "Publishing an artefact" do
    given_there_is_a_draft_artefact_with_subpage
    and_i_publish_it
    then_i_can_view_the_artefact_on_gov_uk
    and_i_can_view_the_subpage_on_gov_uk
  end

private

  def signin_to_signon
    @user = signin_with_next_user(
      "Publisher" => %w[skip_review],
    )
  end

  def given_there_is_a_draft_artefact_with_subpage
    signin_to_signon if use_signon?
    create_publisher_artefact(slug: slug, title: title, format: "Guide")
    add_part_to_artefact(title: unique_title)
    @subpart_slug = add_part_to_artefact(title: subpart_title)
  end

  def and_i_publish_it
    publish_artefact
  end

  def then_i_can_view_the_artefact_on_gov_uk
    wait_for_artefact_to_be_published

    click_link("View this on the GOV.UK website")
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
  end

  def and_i_can_view_the_subpage_on_gov_uk
    visit(subpage_url)
    expect(page).to have_content(subpart_title)
    expect_url_matches_live_gov_uk
  end

  def wait_for_artefact_to_be_published
    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end

  def subpage_url
    [@published_url, @subpart_slug].join("/")
  end
end
