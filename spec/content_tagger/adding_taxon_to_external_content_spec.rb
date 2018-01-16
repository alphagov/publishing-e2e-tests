feature "Adding a taxon to external content", new: true, collections: true, content_tagger: true, publisher: true do
  include ContentTaggerHelpers
  include PublisherHelpers

  let(:taxon_title) { "Tagging external content taxon " + SecureRandom.uuid }
  let(:taxon_slug) { "tagging-taxon-" + SecureRandom.uuid }
  let(:guide_title) { "Tagging external content guide " + SecureRandom.uuid }
  let(:guide_slug) { "tagging-taxon-guide-" + SecureRandom.uuid }

  scenario "Adding a taxon to a publisher guide" do
    given_there_is_a_published_guide
    and_there_is_a_published_taxon
    when_i_tag_the_guide_with_the_taxon
    then_the_taxon_on_gov_uk_links_to_the_guide
  end

  def given_there_is_a_published_guide
    create_publisher_artefact(slug: guide_slug, title: guide_title, format: "Guide")
    add_part_to_artefact(title: title_with_timestamp)
    publish_artefact
  end

  def and_there_is_a_published_taxon
    create_draft_taxon(slug: taxon_slug, title: taxon_title)
    publish_taxon
    @taxon_url = find_link("/" + taxon_slug)[:href]
    reload_url_until_status_code(@taxon_url, 200)
  end

  def when_i_tag_the_guide_with_the_taxon
    visit(Plek.find("content-tagger") + "/taggings/lookup")
    fill_in "content_lookup_form_base_path", with: "/" + guide_slug
    click_button "Edit page"
    select2(taxon_title, css: "#s2id_tagging_tagging_update_form_taxons")
    click_button "Update tagging"
  end

  def then_the_taxon_on_gov_uk_links_to_the_guide
    reload_url_until_match(@taxon_url, :has_text?, guide_title)
    visit(@taxon_url)
    expect(page).to have_content(taxon_title)
    expect(page).to have_content(guide_title)
    expect_url_matches_live_gov_uk
    expect_rendering_application("collections")
  end
end
