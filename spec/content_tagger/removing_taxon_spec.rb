feature "Removing content from Content Tagger", collections: true, content_tagger: true do
  include ContentTaggerHelpers

  let(:redirection_destination_title) { "Removed taxon destination " + SecureRandom.uuid }
  let(:redirection_destination_slug) { "redirection-taxon-" + SecureRandom.uuid }
  let(:removed_slug) { "removed-taxon-" + SecureRandom.uuid }

  scenario "Unpublishing a taxon" do
    given_there_are_two_published_taxons
    and_i_remove_one_by_redirecting_to_the_other
    then_visiting_the_removed_taxon_redirects_to_the_other_taxon
  end

  def given_there_are_two_published_taxons
    @redirection_destination_url = create_and_publish_taxon(slug: redirection_destination_slug, title: redirection_destination_title)
    reload_url_until_status_code(@redirection_destination_url, 200)

    @redirected_taxon_url = create_and_publish_taxon(slug: removed_slug, title: "Removed taxon " + SecureRandom.uuid)
    reload_url_until_status_code(@redirected_taxon_url, 200)
  end

  def and_i_remove_one_by_redirecting_to_the_other
    click_link "Unpublish"
    select2(redirection_destination_title, from: "Redirect to")
    click_button "Delete and redirect"
  end

  def then_visiting_the_removed_taxon_redirects_to_the_other_taxon
    reload_url_until_status_code(@redirected_taxon_url, 301, keep_retrying_while: [200])
    visit @redirected_taxon_url
    expect_rendering_application("collections")
    expect(current_url).to eq(@redirection_destination_url)
  end

  private

  def create_and_publish_taxon(slug:, title:)
    create_draft_taxon(slug: slug, title: title)
    publish_taxon
    find_link("/" + slug)[:href]
  end
end
