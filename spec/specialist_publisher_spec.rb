require "spec_helper"
require "plek"
require "faker"
require "date"

describe "specialist publisher", type: :feature do
  feature "Publishes an AAIB Report" do
    let(:title) { Faker::Book.title }
    let(:summary) { Faker::Lorem.sentence }

    scenario "successfully" do
      create_aaib_report(title, summary, Faker::Lorem.paragraph)
      save_and_publish
      view_frontend
      expect_title(title)
      expect_rendering_app_meta
      expect(page).to have_current_path(%r{^/aaib-reports})
    end

    scenario "unsuccessfully" do
      create_aaib_report(title, "", Faker::Lorem.paragraph)
      save_draft
      expect_error("Summary can't be blank")
    end
  end

  feature "Creates a draft of an AAIB Report" do
    let(:title) { Faker::Book.title }
    let(:summary) { "Aubergine crop has failed in Turkmenistan" }

    scenario "successfully" do
      create_aaib_report(title, summary, Faker::Lorem.paragraph)
      save_draft
      preview_draft
      expect_title(title)
    end
  end

  feature "Edit an AAIB report" do
    let(:title) { "Eat more falafel" }
    let(:change_note) { "Fixed title to have a clearer falafel orientation" }

    before do
      ensure_published_aaib_report
    end

    scenario "Minor edit" do
      visit_aaib_index
      edit_first_published_document
      fill_in("Title", with: title)
      set_minor_update
      save_and_publish
      view_frontend
      expect_title(title)
    end

    scenario "Major edit" do
      visit_aaib_index
      edit_first_published_document
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
    before do
      ensure_published_aaib_report
    end

    scenario "successfully" do
      visit_aaib_index
      visit_first_published_document
      unpublish
      expect_unpublished
    end
  end
end
