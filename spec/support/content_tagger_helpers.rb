module ContentTaggerHelpers
  def create_draft_taxon(slug:, title:)
    visit(Plek.find("content-tagger") + "/taxons/new")
    fill_in "Path", with: slug
    fill_in "Internal taxon name", with: title
    fill_in "External taxon name", with: title
    fill_in "Description", with: Faker::Lorem.paragraph
    click_button "Create taxon"
  end
end
