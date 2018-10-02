feature "Uploading an attachment on Manuals Publisher", manuals_publisher: true do
  include ManualsPublisherHelpers

  let(:title) { "Uploading atttachent to manual #{SecureRandom.uuid}" }
  let(:section_title) { unique_title }
  let(:attachment_title) { "Uploading atttachent to manual attachment #{SecureRandom.uuid}" }
  let(:file) { File.expand_path("../fixtures/manuals_publisher/manuals.png", __dir__) }

  scenario "Uploading an attachment to a manual" do
    given_there_is_a_draft_manual_with_a_section
    when_i_upload_an_attachment
    and_add_the_attachment_to_the_draft
    then_i_can_access_the_attachment_through_the_draft
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Manuals Publisher" => %w[editor gds_editor],
    )
  end

  def given_there_is_a_draft_manual_with_a_section
    signin_to_signon if use_signon?

    create_draft_manual(title: title)
    create_manual_section(title: section_title)
  end

  def when_i_upload_an_attachment
    click_link(section_title)
    click_link("Edit section")
    click_link("Add attachment")

    fill_in("Title", with: attachment_title)
    attach_file("File", file)
    click_button("Save attachment")

    expect(page).to have_content(attachment_title)
  end

  def and_add_the_attachment_to_the_draft
    attachment_text = find("span", text: /\[InlineAttachment/).text
    fill_in("Section body", with: attachment_text)

    click_button("Save as draft")
  end

  def then_i_can_access_the_attachment_through_the_draft
    visit_draft_manual

    section_url = find_link(section_title)[:href]
    reload_url_until_match(section_url, :has_text?, attachment_title)

    click_link(section_title)
    expect_rendering_application("manuals-frontend")
    expect_url_matches_draft_gov_uk

    attachment_link = find_link(attachment_title)[:href]
    reload_url_until_status_code(attachment_link, 200)

    expect_matching_uploaded_file(attachment_link, file)
  end

  def visit_draft_manual
    signin_to_draft_origin(@user) if use_signon?

    url = find_link("Preview draft")[:href]
    reload_url_until_status_code(url, 200)

    click_link("Preview draft")
    expect_rendering_application("manuals-frontend")
  end
end
