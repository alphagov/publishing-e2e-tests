feature "Updating a published taxon on Content Tagger", collections: true, content_tagger: true do
  include ContentTaggerHelpers

  let(:title) { "Updating a taxon" + SecureRandom.uuid }
  let(:base_path) { "/updating-taxon" + SecureRandom.uuid }
  let(:updated_content) { "Updated content" + SecureRandom.uuid }

  scenario "Updating a taxon" do
    given_there_is_a_published_taxon
    when_i_update_the_taxon
    and_i_publish_the_taxon
    then_i_can_view_it_on_gov_uk
  end

  private

  def signin_to_signon
    @user = signin_with_next_user(
      "Content Tagger" => ["GDS Editor"],
    )
  end

  def given_there_is_a_published_taxon
    signin_to_signon if use_signon?
    create_draft_taxon(base_path: base_path, title: title)
    publish_taxon

    url = find_link("View on GOV.UK")[:href]
    reload_url_until_status_code(url, 200)
  end

  def when_i_update_the_taxon
    click_link "Edit taxon"
    fill_in "Description", with: updated_content
    click_button "Save draft"
  end

  def and_i_publish_the_taxon
    click_link "Publish"
    click_button "Confirm publish"
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link("View on GOV.UK")[:href]
    reload_url_until_match(url, :has_text?, updated_content)

    click_link "View on GOV.UK"
    expect_rendering_application("collections")
    expect(page).to have_content(title)
    expect(page).to have_content(updated_content)
    expect_url_matches_live_gov_uk
  end
end
