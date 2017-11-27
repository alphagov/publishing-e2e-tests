module ManualsHelpers
  def create_draft_manual(title:)
    visit(Plek.find("manuals-publisher") + "/manuals/new")
    fill_in "Title", with: title
    fill_in "Summary", with: sentence

    click_button "Save as draft"
  end
end
