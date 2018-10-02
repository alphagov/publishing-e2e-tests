module ManualsPublisherHelpers
  def create_draft_manual(title:)
    visit(Plek.find("manuals-publisher") + "/manuals/new")
    fill_in "Title", with: title
    fill_in "Summary", with: sentence

    click_button "Save as draft"
  end

  def create_manual_section(title: unique_title, change_note: nil)
    click_link "Add section"
    fill_in "Section title", with: title
    fill_in "Section summary", with: Faker::Lorem.sentence
    fill_in "Section body", with: Faker::Lorem.paragraph

    if change_note
      fill_in "Change note", with: change_note
    end

    click_button "Save as draft"
  end

  def publish_manual
    page.accept_confirm do
      click_button "Publish manual"
    end
    reload_url_until_match(current_url, :has_text?, "View on website")
    visit current_url
  end
end
