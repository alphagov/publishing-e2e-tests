feature "Adding a facet tag to a finder content", search_api: true, finder_frontend: true, content_tagger: true, new: true do
  include ContentTaggerHelpers
  include PublisherHelpers

  let(:guide_title) { "Rail transport if theres no Brexit deal" }
  let(:guide_slug) { "rail-transport-if-theres-no-brexit-deal" }
  let(:facet_tag) { "Rail (passengers and freight)" }

  scenario "Adding a facet tag to a published document" do
    given_there_is_a_published_document
    when_i_tag_the_document_with_the_facet
    then_the_business_finder_shows_the_document
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Publisher" => %w[skip_review],
      "Content Tagger" => ["GDS Editor"],
    )
  end

  def given_there_is_a_published_document
    signin_to_signon if use_signon?
    create_publisher_artefact(slug: guide_slug, title: guide_title, format: "Answer")
    publish_artefact
    wait_for_artefact_to_be_published
  end

  def when_i_tag_the_document_with_the_facet
    visit(Plek.find("content-tagger"))
    click_link "Facets"
    click_link "Find EU Exit guidance business"
    # '/' is required in the Content Tagger
    fill_in "content_lookup_form_base_path", with: "/#{guide_slug}"
    click_button "Edit page"
    select2("Rail (passengers and freight)", css: "#s2id_facets_tagging_update_form_sector_business_area")
    click_button "Update facet values"
  end

  def then_the_business_finder_shows_the_document
    finder_url = "#{Plek.new.website_root}/find-eu-exit-guidance-business"
    reload_url_until_match(finder_url, :has_text?, guide_title)
    visit(finder_url)
    expect_rendering_application("finder-frontend")
    within('.filtered-results__group') do
      expect(page).to have_content(guide_title)
    end
  end

  def wait_for_artefact_to_be_published
    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end
end
