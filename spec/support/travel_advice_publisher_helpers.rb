module TravelAdvicePublisherHelpers
  def delete_draft_edition(country)
    visit_travel_advice_publisher("/admin")
    click_link(country)
    click_link("edit")
    click_link("Delete")
  rescue Capybara::ElementNotFound
    nil
  end

  def expect_published_alert(country, title = nil)
    fail_reason = "Failed to find acknowledgement of publishing #{country} on "\
      "#{page.current_url}"

    title ||= "#{country} travel advice"

    expect(page).to have_text("#{title} published"), fail_reason
  end

  def expect_updated_alert(country, title = nil)
    fail_reason = "Failed to find acknowledgement of updating #{country} on "\
      "#{page.current_url}"

    title ||= "#{country} travel advice"

    expect(page).to have_text("#{title} updated"), fail_reason
  end

  def fill_in_advice_form(options)
    options = populate_form_defaults(options)

    fill_in("Change description", with: options[:change_description])
    fill_in("Search title", with: options[:search_title]) if options[:search_title]
    fill_in("Summary", with: options[:summary])
    options[:parts].each do |part|
      click_button("Add new part")
      within("#parts > :last-child") do
        fill_in("Title", with: part[:title])
        fill_in("Body", with: part[:body])
        fill_in("Slug", with: part[:slug]) if part[:slug]
      end
    end
  end

  def populate_form_defaults(options)
    part_title = Faker::Book.title
    options = {
      change_description: Faker::Lorem.sentence,
      summary: Faker::Lorem.paragraph,
      parts: [
        { title: part_title, body: Faker::Lorem.sentence }
      ]
    }.merge(options)

    options[:parts] = options[:parts].map do |item|
      title = unique_title
      {
        title: title,
        body: Faker::Lorem.sentence,
      }.merge(item)
    end
    options
  end

  def visit_travel_advice_publisher(path = "/")
    visit(Plek.find("travel-advice-publisher") + path)
  end

  def reload_until_travel_advice_summary_displayed(url, summary)
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, ignore_quotes_regex(summary))
  end
end
