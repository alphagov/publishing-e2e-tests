module TravelAdvicePublisherNavigationHelpers
  def visit_travel_advice_publisher_homepage
    visit_travel_advice_publisher_url("/admin")
  end

  def visit_travel_advice_publisher_url(path)
    visit(Plek.find("travel-advice-publisher") + path)
  end

  def create_new_edition_draft(title, summary, part_title, part_body, country)
    visit_travel_advice_publisher_homepage
    click_link(country)
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

  def delete_existing_draft(country)
    visit_travel_advice_publisher_url("/admin/countries/#{country.downcase}")
    delete_draft unless page.has_button?("Create new edition")
  end

  def preview_edition(country)
    window_opened_by do
      click_link("Preview saved version")
    end
  end

  def delete_draft
    click_link("edit")
    click_link("Delete")
  end

  def view_new_part(part_title)
    click_link(part_title)
  end

  def view_published_frontend(country)
    window_opened_by do
      click_link("view")
    end
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
