feature "Uploading an attachment on Whitehall", whitehall: true, government_frontend: true do
  include WhitehallHelpers

  let(:title) { "Attachment Whitehall #{SecureRandom.uuid}" }
  let(:attachment_file) { File.expand_path("../fixtures/whitehall/public_health.png", __dir__) }
  let(:attachment_alt_text) { "Public Health Attachment" }

  scenario "Uploading an attachment on Whitehall" do
    given_i_have_a_draft_document_with_attachment
    when_i_view_the_draft_document
    then_i_can_view_the_image
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Whitehall" => %w[Editor],
    )
  end

  def given_i_have_a_draft_document_with_attachment
    signin_to_signon if use_signon?
    visit(Plek.find("whitehall-admin") + "/government/admin/consultations/new")
    within(:css, ".file_upload") do
      attach_file("File", attachment_file)
      fill_in "Alt text", with: attachment_alt_text
    end
    image_markdown = "!!1"
    fill_in_consultation_form(title: title, body: "Attached image\n\n#{image_markdown}")
    click_button("Save and continue")
    find(".miller-columns .govuk-checkboxes__item", text: "Test taxon").click
    click_button("Update and review specialist topic tags")
    click_button("Save")
    expect(page).to have_text("The associations have been saved")
  end

  def when_i_view_the_draft_document
    url = find_link("Preview on website")[:href]
    reload_url_until_status_code(url, 200)

    switch_to_window(window_opened_by { click_link("Preview on website") })

    expect_rendering_application("government-frontend")
    expect_url_matches_draft_gov_uk
    expect(page).to have_content(title)
  end

  def then_i_can_view_the_image
    attachment_url = find(:xpath, "//img[@alt=\"#{attachment_alt_text}\"]")[:src]

    # Asset manager returns a 302 to a placeholder image until the asset is available
    reload_url_until_status_code(attachment_url, 200, keep_retrying_while: [302, 404])
    expect_matching_uploaded_file(attachment_url, attachment_file)
  end
end
