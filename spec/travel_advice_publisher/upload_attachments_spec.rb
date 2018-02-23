feature "Upload attachments on Travel Advice Publisher", feature: true, travel_advice_publisher: true, government_frontend: true do
  include TravelAdvicePublisherHelpers

  let(:country) { "Congo" }
  let(:summary) { paragraph_with_timestamp }
  let(:image_file) { File.expand_path("../fixtures/travel_advice_publisher/congo_map.jpg", __dir__) }
  let(:document_file) { File.expand_path("../fixtures/travel_advice_publisher/congo_travel_advice.pdf", __dir__) }

  scenario "Uploading attachments for Congo" do
    when_i_create_a_draft_of_congo
    and_i_upload_files_to_it
    then_i_can_view_these_files_on_draft_gov_uk
  end

  after { delete_draft_edition(country) }

  def signin_to_signon
    signin_with_next_user(
      "Travel Advice Publisher" => ["gds_editor"],
      "Content Preview" => [],
    )
  end

  def when_i_create_a_draft_of_congo
    signin_to_signon if use_signon?
    visit_travel_advice_publisher("/admin")
    click_link(country)

    click_button("Create new edition")

    fill_in_advice_form(summary: summary)
  end

  def and_i_upload_files_to_it
    attach_file("edition_image", image_file)
    attach_file("edition_document", document_file)
    click_button("Save")

    expect_updated_alert(country)
  end

  def then_i_can_view_these_files_on_draft_gov_uk
    url = find_link("Preview saved version")[:href]
    reload_until_travel_advice_summary_displayed(url, summary)

    window = window_opened_by { click_link("Preview saved version") }
    within_window(window) do
      expect_rendering_application("government-frontend")
      expect_url_matches_draft_gov_uk
      expect(page).to have_content(ignore_quotes_regex(summary))

      image_url = find(".map img")[:src]
      reload_url_until_status_code(image_url, 200)
      expect_matching_uploaded_file(image_url, image_file)

      document_url = find_link("Download map (PDF)")[:href]
      reload_url_until_status_code(document_url, 200)
      expect_matching_uploaded_file(document_url, document_file)
    end
  end
end
