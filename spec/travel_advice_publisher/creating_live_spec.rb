feature "Creating a live edition on Travel Advice Publisher", feature: true, travel_advice_publisher: true do
  include TravelAdvicePublisherHelpers

  let(:country) { "Malta" }
  let(:summary) { paragraph_with_timestamp }
  let(:part_title) { title_with_timestamp }
  let(:part_body) { Faker::Lorem.sentence }

  scenario "Creating a live edition of Malta" do
    when_i_create_a_live_edition_of_malta
    then_i_can_view_it_on_gov_uk
    and_i_can_view_parts_of_it
  end

  def when_i_create_a_live_edition_of_malta
    visit_travel_advice_publisher("/admin")
    click_link(country)

    click_button("Create new edition")

    fill_in_advice_form(
      summary: summary,
      parts: [
        { title: part_title, body: part_body },
      ]
    )

    click_button("Save & Publish")
    expect_published_alert(country)
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link("view")[:href]
    reload_until_travel_advice_summary_displayed(url, summary)

    @window = window_opened_by { click_link("view") }
    within_window(@window) do
      expect_rendering_application("government-frontend")
      expect(page).to have_content(ignore_quotes_regex(summary))
    end
  end

  def and_i_can_view_parts_of_it
    within_window(@window) do
      click_link(part_title)
      expect(page).to have_content(part_body)
    end
  end
end
