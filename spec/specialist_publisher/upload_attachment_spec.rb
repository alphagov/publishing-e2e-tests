require "httparty"

feature "Uploading an attachment on Specialist Publisher", specialist_publisher: true, government_frontend: true do
  include SpecialistPublisherHelpers

  let(:title) { "Uploading an attachment to a EAT decision #{SecureRandom.uuid}" }
  let(:attachment_title) { "Uploading an attachment to a EAT decision attachment #{SecureRandom.uuid}" }
  let(:file) { File.expand_path("../fixtures/specialist_publisher/tax_returns.pdf", __dir__) }

  scenario "Uploading an attachment to a EAT decision" do
    given_there_is_a_draft_eat_decision
    when_i_upload_an_attachment
    and_add_the_attachment_to_the_draft
    then_i_can_access_the_attachment_through_the_draft
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Specialist Publisher" => %w[editor gds_editor],
      "Content Preview" => [],
    )
  end

  def given_there_is_a_draft_eat_decision
    signin_to_signon if use_signon?
    visit_specialist_publisher("/employment-appeal-tribunal-decisions/new")

    fill_in_eat_decision_form(title: title)

    click_button("Save as draft")
    expect_created_alert(title)
  end

  def when_i_upload_an_attachment
    click_link("Edit document")
    click_link("Add attachment")

    fill_in("Title", with: attachment_title)
    attach_file("File", file)
    click_button("Save attachment")

    expect_attached_alert(attachment_title)
  end

  def and_add_the_attachment_to_the_draft
    attachment_text = find("span", text: /\[InlineAttachment/).text
    fill_in("Body", with: attachment_text)

    click_button("Save as draft")
    expect_updated_alert(title)
  end

  def then_i_can_access_the_attachment_through_the_draft
    signin_to_draft_origin(@user) if use_signon?

    url = find_link("Preview draft")[:href]

    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_link?, attachment_title)

    click_link("Preview draft")

    attachment_link = find_link(attachment_title)[:href]
    reload_url_until_status_code(attachment_link, 200)

    expect_matching_uploaded_file(attachment_link, file)
  end
end
