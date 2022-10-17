require_relative "javascript_helpers"

module PublisherHelpers
  include JavascriptHelpers

  def visit_publisher(path = "/")
    visit(Plek.find("publisher") + path)
  end

  def create_publisher_artefact(slug:, title:, format: "Transaction")
    visit_publisher("/artefacts/new")

    fill_in_new_artefact_form(title:, slug:, format:)

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
    confirm_dialog_action(link: "2nd pair of eyes", button: "Send to 2nd pair of eyes")
    confirm_dialog_action(link: "Skip review", button: "Skip review")
    confirm_dialog_action(link: "Publish", button: "Send to publish")
  end

  def confirm_dialog_action(link:, button:)
    wait_for_link link
    submit_button button

    expect(page).to have_text("edition was successfully updated.")
  end

  def wait_for_link(link)
    find(:xpath, "//a[text()=\"#{link}\"][not(contains(@class, \"disabled\"))]")
  end

  def submit_button(button)
    if is_button_visible?(button)
      click_button(button)
    else
      page.execute_script(%($("input[value='#{button}']").trigger("click");))
    end
  end

  def is_button_visible?(button)
    find_button button
    true
  rescue Capybara::ElementNotFound
    false
  end

  def scroll_to_bottom
    # this app has an overlay popup which sometimes obscures buttons
    # by calling this method, it should means the buttons are no longer obscured
    execute_script("window.scrollBy(0, 10000)")
  end

  def wait_for_workflow_message_to_hide
    page.has_no_css?(".workflow-message", visible: true)
  end

  def add_part_to_artefact(title:, body: sentence)
    # The parts collapse is animated, so disable this to avoid the
    # test not being able to find the parts
    disable_jquery_transitions

    wait_for_jquery_ready_event

    scroll_to_bottom
    click_link "Add new part"

    slug = within("div#untitled-part") do
      fill_in "Title", with: title
      fill_in "Body", with: body
      find_field("Slug").value
    end

    wait_for_workflow_message_to_hide
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
