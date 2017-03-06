module SpecialistPublisherAssertionHelpers
  def expect_title(title)
    reload_page_while_failing do
      within(".govuk-title") do
        expect(page).to have_content(title)
      end
    end
  end

  def expect_change_note(change_note)
    reload_page_while_failing do
      click_link("+ full page history")
      within("#full-history") do
        expect(page).to have_content(change_note)
      end
    end
  end

  def expect_rendering_app_meta
    reload_page_while_failing do
      expect(page).to have_selector(
        "meta[name='govuk:rendering-application'][content='specialist-frontend']",
        visible: false
      )
    end
  end

  def expect_preview_draft_link
    expect(page).to have_link("Preview draft")
  end

  def expect_view_on_website_link
    expect(page).to have_link("View on website")
  end

  def expect_unpublished
    expect(find(".alert").text).to match(/^Unpublished/)
  end

  def expect_discarded_draft
    expect(find(".alert").text).to match(/^Discarded/)
  end

  def expect_attachment_removed
    expect(find(".alert").text).to match(/^Attachment/)
  end

  def expect_published_document
    expect(page).to have_content("There are no changes to publish.")
    expect_view_on_website_link
  end

  def expect_add_attachment
    within(".page-header")do
      expect(page).to have_content("Add attachment")
    end
  end

  def expect_attached_file_frontend
    reload_page_while_failing do
      within(".govuk-govspeak")do
        expect(page).to have_link("Charities and corporation tax returns doc")
      end
    end
  end

  def expect_removed_file_frontend
    within(".govuk-govspeak")do
      expect(page).to have_content("Removed attached document")
    end
  end

  def expect_attached_file
    expect(page).to have_content("1 attachment")
  end

  def expect_attached_file_removed
    expect(page).to have_content("0 attachments")
  end

  def expect_unpublished_document
    expect(page).not_to have_button("Publish")
    expect(page).to have_content("The document is already unpublished.")
  end

  RSpec.configuration.include SpecialistPublisherAssertionHelpers
end
