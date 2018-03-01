feature "Publishing a taxon on Content Tagger", collections: true, content_tagger: true do
  include ContentTaggerHelpers

  let(:title) { "Publishing a taxon #{SecureRandom.uuid}" }
  let(:slug) { "publishing-taxon-#{SecureRandom.uuid}" }

  scenario "Publishing a taxon" do
    given_there_is_a_draft_taxon
    when_i_publish_the_taxon
    then_i_can_view_it_on_gov_uk
  end

  def given_there_is_a_draft_taxon
    create_draft_taxon(slug: slug, title: title)
  end

  def when_i_publish_the_taxon
    publish_taxon
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link("View on GOV.UK")[:href]
    reload_url_until_status_code(url, 200)

    click_link "View on GOV.UK"
    expect_rendering_application("collections")
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
  end
end
