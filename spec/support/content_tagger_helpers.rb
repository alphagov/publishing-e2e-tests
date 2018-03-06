module ContentTaggerHelpers
  def create_draft_taxon(base_path:, title:)
    visit(Plek.find("content-tagger") + "/taxons/new")
    fill_in "Base path", with: base_path
    fill_in "Internal taxon name", with: title
    fill_in "External taxon name", with: title
    fill_in "Description", with: Faker::Lorem.paragraph
    click_button "Create taxon"
  end

  def publish_taxon
    click_link "Publish"
    click_button "Confirm publish"
  end

  def visit_tag_external_content_page(slug:)
    visit(Plek.find("content-tagger") + "/taggings/lookup")
    fill_in "content_lookup_form_base_path", with: "/" + slug
    click_button "Edit page"
  end
end
