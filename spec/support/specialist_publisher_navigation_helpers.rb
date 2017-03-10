module SpecialistPublisherNavigationHelpers
  def visit_aaib_index
    specialist_publisher_url("/aaib-reports")
  end

  def visit_aaib_create
    specialist_publisher_url("/aaib-reports/new")
  end

  def visit_esi_index
    specialist_publisher_url("/esi-funds")
  end

  def visit_esi_create
    specialist_publisher_url("/esi-funds/new")
  end

  def specialist_publisher_url(path)
    visit(Plek.find("specialist-publisher") + path)
  end

  def aaib_occurence_date(date)
    fill_in("[aaib_report]date_of_occurrence(1i)", with: date.year)
    fill_in("[aaib_report]date_of_occurrence(2i)", with: date.month)
    fill_in("[aaib_report]date_of_occurrence(3i)", with: date.day)
  end

  def esi_fund_closing_date(date)
    fill_in("[esi_fund]closing_date(1i)", with: date.year)
    fill_in("[esi_fund]closing_date(2i)", with: date.month)
    fill_in("[esi_fund]closing_date(3i)", with: date.day)
  end

  def edit_first_document
    first(".document-title").click
    click_link("Edit document")
  end

  def visit_first_published_document
    all(".document-list span")
      .select { |elem| elem.text.strip == "published" }.first
      .find(:xpath, "../../..").first("a").click
  rescue NoMethodError
    raise "Published document not found"
  end

  def visit_first_unpublished_document
    all(".document-list span")
      .select { |elem| elem.text.strip == "unpublished" }.first
      .find(:xpath, "../../..").first("a").click
  rescue NoMethodError
    raise "Unpublished document not found"
  end

  def select_drafted_content
    all(".document-list span")
      .select { |elem| elem.text.strip == "draft" }.first
      .find(:xpath, "../../..").first("a").click
  rescue NoMethodError
    raise "Draft document not found"
  end

  def select_published_with_new_draft
    all(".document-list span")
      .select { |elem| elem.text.strip == "published with new draft" }.first
      .find(:xpath, "../../..").first("a").click
  rescue NoMethodError
    raise "Published-with-new-draft document not found"
  end

  def edit_first_published_document
    visit_first_published_document
    click_link("Edit document")
  end

  def edit_first_unpublished_document
    visit_first_unpublished_document
    click_link("Edit document")
  end

  def edit_unpublished_document
    click_link("Edit document")
  end

  def edit_first_draft_document
    select_drafted_content
    click_link("Edit document")
  end

  def save_draft
    click_button("Save as draft")
  end

  def publish_draft
    page.accept_confirm do
      click_button("Publish")
    end
  end

  def save_and_publish
    save_draft
    page.accept_confirm do
      click_button("Publish")
    end
  end

  def save_and_edit_draft
    save_draft
    click_link("Edit document")
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

  def ensure_published_aaib_report
    create_aaib_report(title_timestamp, "Summary", "Body")
    save_and_publish
  end

  def ensure_published_esi_fund
    create_esi_fund(title, summary, Faker::Lorem.paragraph)
    save_and_publish
  end

  def select_delete_attachment
    page.accept_confirm do
      click_button("delete")
    end
  end

  def select_add_attachment
    click_link("Add attachment")
    expect_add_attachment
    fill_in("Title", with: "Charities and corporation tax returns doc")
    attach_file("attachment_file", file)
    click_button("Save attachment")
    fill_in("Body", with: "[InlineAttachment:Charities_and_corporation_tax_returns.pdf]")
  end

  def remove_attachment_and_save_draft
    select_delete_attachment
    expect_attachment_removed
    fill_in("Summary", with: "Removing the attachment")
    fill_in("Body", with: "Removed attached document")
    save_draft
  end

  def create_aaib_report(title, summary, body)
    visit_aaib_create
    fill_in("Title", with: title)
    fill_in("Summary", with: summary)
    fill_in("Body", with: body)
    aaib_occurence_date(Date.today)
  end

  def create_esi_fund(title, summary, body)
    visit_esi_create
    fill_in("Title", with: title)
    fill_in("Summary", with: summary)
    fill_in("Body", with: body)
    esi_fund_closing_date(Date.today)
  end

  def title_timestamp
    Faker::Book.author << " #{Time.now.to_i}"
  end

  def discard_draft
    page.accept_confirm do
      click_button("Discard draft")
    end
  end

  RSpec.configuration.include SpecialistPublisherNavigationHelpers
end
