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

  def fill_in_schedule_downtime_form(date)
    select(date.day, from: "downtime_start_time_3i")
    select(Date::MONTHNAMES[Date.today.month], from: "downtime_start_time_2i")
    select(date.year, from: "downtime_start_time_1i")
  end

  def publish_artefact
    confirm_action(link: "2nd pair of eyes", button: "Send to 2nd pair of eyes")
    confirm_action(link: "Skip review", button: "Skip review")
    confirm_action(link: "Publish", button: "Send to publish")
  end

  def confirm_action(link:, button:)
    click_link link
    click_button button

    expect(page).to have_text('Transaction edition was successfully updated.')
  end

  def add_part_to_artefact(title:, body: sentence)
    click_link "Add new part"

    slug = within("div#untitled-part") do
      fill_in "Title", with: title
      fill_in "Body", with: body
      find_field("Slug").value
    end
    click_button "Save"
    slug
  end

  def switch_to_tab(tab)
    click_link tab
  end

  def wait_for_artefact_to_be_viewable(url)
    reload_url_until_status_code(url, 200)
  end
end
