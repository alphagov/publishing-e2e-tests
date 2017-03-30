require "spec_helper"
require "httparty"

feature "Uploading an attachment on Specialist Publisher", specialist_publisher: true do
  include SpecialistPublisherHelpers

  let(:title) { title_with_timestamp }
  let(:attachment_title) { Faker::Book.title }
  let(:file) { File.expand_path("../fixtures/Charities_and_corporation_tax_returns.pdf", __dir__) }

  scenario "Uploading an attachment to a EAT decision" do
    given_there_is_a_draft_eat_decision
    when_i_upload_an_attachment
    and_add_the_attachment_to_the_draft
    then_i_can_access_the_attachment_through_the_draft
  end

  def given_there_is_a_draft_eat_decision
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
    click_link("Preview draft")
    reload_page_until(:has_link?, attachment_title)

    attachment_link = find_link(attachment_title)[:href]
    reload_url_until_status_code(attachment_link, 200)

    uploaded_file = HTTParty.get(attachment_link)
    file_contents = File.read(file, encoding: uploaded_file.body.encoding)
    expect(uploaded_file.body).to eq file_contents
  end
end
