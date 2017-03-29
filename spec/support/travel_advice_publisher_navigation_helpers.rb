module TravelAdvicePublisherNavigationHelpers
  def visit_travel_advice_publisher_homepage
    visit_travel_advice_publisher_url("/admin")
  end

  def visit_draft_origin_url(path)
    visit(Plek.find("draft-origin") + path)
  end

  def visit_published_url(path)
    visit(Plek.find("www") + path)
  end

  def visit_travel_advice_publisher_url(path)
    visit(Plek.find("travel-advice-publisher") + path)
  end

  def create_new_edition_draft(title, summary, part_title, part_body)
    visit_travel_advice_publisher_homepage
    click_link("Argentina")
    expect_create_new_edition
    click_button("Create new edition")
    fill_in("edition_change_description", with: title)
    fill_in("edition_summary", with: summary)
    add_new_part(part_title, part_body)
  end

  def add_new_part(part_title, part_body)
    click_button("Add new part")
    within(".panel-body") do
      find(".title").set(part_title)
      find("textarea").set(part_body)
    end
  end

  def attach_a_files
    attach_file("edition_image", image)
    attach_file("edition_document", file)
  end

  def select_draft_edition
    visit_travel_advice_homepage
  end

  def delete_existing_draft
    travel_advice_publisher_url("/admin/countries/argentina")
    delete_draft unless page.has_button?("Create new edition")
  end

  def preview_edition
    click_link("Preview saved version")
    view_draft_frontend
  end

  def delete_draft
    click_link("edit")
    click_link("Delete")
  end

  def view_new_part(part_title)
    click_link(part_title)
  end

  def view_draft_frontend
    visit_draft_origin_url("/foreign-travel-advice/argentina")
  end

  def view_published_frontend
    click_link("view")
    visit_published_url("/foreign-travel-advice/argentina")
  end

  def download_example_pdf
    click_link("Download map (PDF)")
  end

  def save_new_edition
    click_button("Save")
    expect_draft_updated
  end

  def save_draft_publish
    click_button("Save & Publish")
    expect_draft_published
  end

  RSpec.configuration.include TravelAdvicePublisherNavigationHelpers
end
