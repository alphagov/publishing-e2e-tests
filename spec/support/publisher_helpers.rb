module PublisherHelpers
  def visit_publisher(path = "/")
    visit(Plek.find("publisher") + path)
  end

  def create_publisher_artefact(slug:, title:, format: "Transaction")
    visit_publisher("/artefacts/new")

    fill_in_new_artefact_form(title: title, slug: slug, format: format)

    click_button "Save and go to item"
    expect(page).to have_text(title)
  end

  def fill_in_new_artefact_form(title:, slug:, format:)
    fill_in "Title", with: title
    fill_in "Slug", with: slug
    select format, from: "Format"
  end

  def confirm_action(link:, button:)
    click_link link
    click_button button

    expect(page).to have_text('Transaction edition was successfully updated.')
  end

  def switch_to_tab(tab)
    click_link tab
  end

  def wait_for_artefact_to_be_viewable(url)
    reload_url_until_status_code(url, 200)
  end
end
