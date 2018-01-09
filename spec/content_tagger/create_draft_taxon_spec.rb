feature "Creating a draft taxon on Content Tagger", new: true, content_tagger: true do
  let(:title) { "Create Draft Taxon" + SecureRandom.uuid }
  let(:slug) { "draft-taxon" + SecureRandom.uuid }

  scenario "Creating a draft taxon" do
    when_i_create_a_new_taxon
    then_i_can_preview_it_on_draft_gov_uk
  end

  def when_i_create_a_new_taxon
    visit(Plek.find("content-tagger") + "/taxons/new")
    fill_in "Path", with: slug
    fill_in "Internal taxon name", with: title
    fill_in "External taxon name", with: title
    fill_in "Description", with: Faker::Lorem.paragraph
    click_button "Create taxon"
  end

  def then_i_can_preview_it_on_draft_gov_uk
    url = find_link("/" + slug)[:href]
    reload_url_until_status_code(url, 200)

    click_link "/" + slug
    expect(page).to have_content(title)
    expect_url_matches_draft_gov_uk
    expect_rendering_application("collections")
  end
end
