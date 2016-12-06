module SpecialistPublisherNavigationHelpers
  def visit_aaib_index
    visit("#{Plek.new.find('specialist-publisher')}/aaib-reports")
  end

  def visit_aaib_create
    visit("#{Plek.new.find('specialist-publisher')}/aaib-reports/new")
  end

  def set_aaib_occurence_date(date)
    fill_in("[aaib_report]date_of_occurrence(1i)", with: date.year)
    fill_in("[aaib_report]date_of_occurrence(2i)", with: date.month)
    fill_in("[aaib_report]date_of_occurrence(3i)", with: date.day)
  end

  def edit_first_document
    first(".document-title").click
    click_link("Edit document")
  end

  def edit_first_published_document
    all(".document-list span")
      .select { |elem| elem.text.strip == "published" }.first
      .find(:xpath, "../../..").first("a").click
  end

  def save_draft
    click_button("Save as draft")
  end

  def save_and_publish
    save_draft
    click_button("Publish")
  end

  def view_frontend
    click_link("View on website")
  end

  def preview_draft
    click_link("Preview draft")
  end

  def set_minor_update
    choose("Update type minor")
  end

  def set_major_update
    choose("Update type major")
  end

  def unpublish
    page.accept_confirm do
      click_button("Unpublish document")
    end
  end

  RSpec.configuration.include SpecialistPublisherNavigationHelpers
end
