require "spec_helper"
require "plek"
require "faker"
require "date"

describe "specialist publisher", type: :feature do
  feature "Publishes an AAIB Report" do
    let(:title) { Faker::Book.author }
    let(:summary) { Faker::Lorem.sentence }

    scenario "successfully publishing an AAIB report" do
      create_aaib_report(title, summary, Faker::Lorem.paragraph)
      save_and_publish
      view_frontend
      expect_title(title)
      expect_rendering_app_meta
      expect(page).to have_current_path(%r{^/aaib-reports})
    end
  end

  feature "Creates a draft of an AAIB Report" do
    let(:title) { Faker::Book.author }
    let(:summary) { "Aubergine crop has failed in Turkmenistan" }

    scenario "successfully creating an AAIB report" do
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
      visit_aaib_index
    end

    scenario "Minor editing published documents" do
      edit_first_published_document
      fill_in("Title", with: title)
      set_minor_update
      save_and_publish
      view_frontend
      expect_title(title)
    end

    scenario "publishing - unpublished document with new draft" do
      visit_first_published_document
      unpublish
      expect_unpublished
      visit_aaib_index
      edit_first_unpublished_document
      fill_in("Title", with: title)
      set_minor_update
      save_draft
      expect_preview_draft_link
      publish_draft
      view_frontend
      expect_title(title)
    end

    scenario "Major editing published docucments" do
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

    scenario "Unpublish a document successfully" do
      visit_aaib_index
      visit_first_published_document
      unpublish
      expect_unpublished
    end
  end

  feature "Discarding drafts" do
    let(:title) { Faker::Book.author }
    let(:summary) { "Draft which will be discarded" }

    scenario "Discarding drafts that are not published" do
      create_esi_fund(title, summary, Faker::Lorem.paragraph)
      save_draft
      preview_draft
      expect_title(title)
      visit_esi_index
      select_drafted_content
      discard_draft
      expect_discarded_draft
    end

    before do
      ensure_published_esi_fund
    end

    scenario "Discarding published document with new draft" do
      visit_esi_index
      edit_first_published_document
      fill_in("Title", with: title)
      set_minor_update
      save_draft
      preview_draft
      expect_title(title)
      visit_esi_index
      select_published_with_new_draft
      discard_draft
      expect_discarded_draft
      visit_first_published_document
      expect_published_document
    end

    scenario "Discarding unpublished document with new draft" do
      unpublish
      visit_esi_index
      edit_first_unpublished_document
      fill_in("Title", with: title)
      set_minor_update
      save_draft
      expect_preview_draft_link
      discard_draft
      expect_discarded_draft
      visit_first_unpublished_document
      expect_unpublished_document
    end
  end

  feature "Documents with attachment" do
    let(:title) { Faker::Book.author }
    let(:summary) { "Documents with attachment" }
    let(:file) { File.expand_path("./fixtures/Charities_and_corporation_tax_returns.pdf", File.dirname(__FILE__)) }

    before do
      create_aaib_report(title, summary, Faker::Lorem.paragraph)
      save_and_edit_draft
      select_add_attachment
      save_draft
      expect_attached_file
      publish_draft
    end

    scenario "Publishing documents with attachment" do
      view_frontend
      expect_attached_file_frontend
    end

    scenario "Removing attachments and publishing draft" do
      visit_aaib_index
      edit_first_published_document
      remove_attachment_and_save_draft
      expect_preview_draft_link
      publish_draft
      view_frontend
      expect_removed_file_frontend
    end
  end
end
