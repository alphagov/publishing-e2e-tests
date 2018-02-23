feature "Creating a draft on Travel Advice Publisher", feature: true, travel_advice_publisher: true, government_frontend: true do
  include TravelAdvicePublisherHelpers

  let(:country) { "Chad" }
  let(:summary) { paragraph_with_timestamp }
  let(:part_title) { unique_title }
  let(:part_body) { Faker::Lorem.sentence }

  scenario "Creating a draft of Chad" do
    when_i_create_a_draft_of_chad
    then_i_can_preview_it_on_draft_gov_uk
    and_i_can_view_parts_of_it
  end

  after { delete_draft_edition(country) }

  def signin_to_signon
    @user = signin_with_next_user(
      "Travel Advice Publisher" => ["gds_editor"],
      "Content Preview" => []
    )
  end

  def when_i_create_a_draft_of_chad
    signin_to_signon if use_signon?
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
    signin_to_draft_origin(@user) if use_signon?

    url = find_link("Preview saved version")[:href]
    reload_until_travel_advice_summary_displayed(url, summary)

    @window = window_opened_by { click_link("Preview saved version") }
    within_window(@window) do
      expect_rendering_application("government-frontend")
      expect_url_matches_draft_gov_uk
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
