require "spec_helper"
require "plek"
require "faker"
require "date"

describe "specialist publisher", type: :feature do

  feature "Publishes an AAIB Report" do
    let(:title) { Faker::Book.title }
    let(:summary) { Faker::Lorem.sentence }

    scenario "successfully" do
      visit_aaib_create
      fill_in("Title", with: title)
      fill_in("Summary", with: summary)
      fill_in("Body", with: Faker::Lorem.paragraph)
      set_aaib_occurence_date(Date.today)
      save_and_publish
      view_frontend
      expect_title(title)
      expect_rendering_app_meta
      expect(page).to have_current_path(%r{^/aaib-reports})
    end

    scenario "unsuccessfully" do
      visit_aaib_create
      fill_in("Title", with: title)
      set_aaib_occurence_date(Date.today)
      click_button("Save as draft")
      expect_error("Summary can't be blank")
    end
  end

  feature "Edit an AAIB report" do
    let(:title) { "Eat more falafel" }
    let(:change_note) { "Fixed title to have a clearer falafel orientation" }

    scenario "Minor edit" do
      visit_aaib_index
      edit_first_document
      fill_in("Title", with: title)
      set_minor_update
      save_and_publish
      view_frontend
      expect_title(title)
    end

    scenario "Major edit" do
      visit_aaib_index
      edit_first_document
      fill_in("Title", with: title)
      set_major_update
      fill_in("Change note", with: change_note)
      save_and_publish
      view_frontend
      expect_title(title)
      expect_change_note(change_note)
    end
  end

  feature "Unpublish" do
    scenario "successfully" do
      visit_aaib_index
      edit_first_published_document
      unpublish
      expect_unpublished
    end
  end
end
