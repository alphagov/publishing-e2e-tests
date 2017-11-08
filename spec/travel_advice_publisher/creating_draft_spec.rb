feature "Creating a draft on Travel Advice Publisher", feature: true, travel_advice_publisher: true do
  include TravelAdvicePublisherHelpers

  let(:country) { "Chad" }
  let(:summary) { paragraph_with_timestamp }
  let(:part_title) { title_with_timestamp }
  let(:part_body) { Faker::Lorem.sentence }

  scenario "Creating a draft of Chad" do
    when_i_create_a_draft_of_chad
    then_i_can_preview_it_on_draft_gov_uk
    and_i_can_view_parts_of_it
  end

  after { delete_draft_edition(country) }

  def when_i_create_a_draft_of_chad
    visit_travel_advice_publisher("/admin")
    click_link(country)

    click_button("Create new edition")

    fill_in_advice_form(
      summary: summary,
      parts: [
        { title: part_title, body: part_body },
      ]
    )

    click_button("Save")
    expect_updated_alert(country)
  end

  def then_i_can_preview_it_on_draft_gov_uk
    url = find_link("Preview saved version")[:href]
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, ignore_quotes_regex(summary))

    @window = window_opened_by { click_link("Preview saved version") }
    within_window(@window) do
      expect_rendering_application("draft-government-frontend")
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
