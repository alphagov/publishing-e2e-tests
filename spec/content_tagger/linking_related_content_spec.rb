feature "Adding related content to Publisher content", content_tagger: true, frontend: true, publisher: true do
  include ContentTaggerHelpers
  include PublisherHelpers

  let(:guide_title) { "Transaction with related content " + SecureRandom.uuid }
  let(:guide_slug) { "transaction-with-related-content-" + SecureRandom.uuid }
  let(:related_content_title) { "Related transaction " + SecureRandom.uuid }
  let(:related_content_slug) { "related-transaction-" + SecureRandom.uuid }

  scenario "Adding related content to a Publisher guide" do
    given_there_is_a_published_guide
    when_i_add_related_content_to_the_guide
    then_the_related_content_is_linked_to_from_the_guide
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Publisher" => ["skip_review"],
      "Content Tagger" => ["GDS Editor"],
    )
  end

  def given_there_is_a_published_guide
    signin_to_signon if use_signon?
    @guide_url = create_and_publish_guide(slug: guide_slug, title: guide_title)
  end

  def when_i_add_related_content_to_the_guide
    @related_content_url = create_and_publish_guide(slug: related_content_slug, title: related_content_title)
    visit_tag_external_content_page(slug: guide_slug)

    find("input.new-base-path").set("/" + related_content_slug)
    click_button "Add related item"
    expect(page).to have_text(related_content_slug)
    click_button "Update tagging"
    expect(page).to have_text("Tags have been updated!")
  end

  def then_the_related_content_is_linked_to_from_the_guide
    reload_url_until_status_code(@guide_url, 200)
    reload_url_until_match(@guide_url, :has_text?, related_content_title)
    visit(@guide_url)

    expect_rendering_application("frontend")
    related_content_link = find_link(related_content_title)[:href]

    expect(related_content_link).to eq(@related_content_url)
    expect_url_matches_live_gov_uk
  end

  def create_and_publish_guide(slug:, title:)
    create_publisher_artefact(slug: slug, title: title)
    publish_artefact
    find_link("View this on the GOV.UK website")[:href]
  end
end
