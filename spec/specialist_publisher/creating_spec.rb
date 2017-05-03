feature "Creating a draft on Specialist Publisher", specialist_publisher: true do
  include SpecialistPublisherHelpers

  let(:title) { title_with_timestamp }

  scenario "Creating a Business Finance Support Scheme" do
    when_i_create_a_business_finance_support_scheme
    then_i_can_preview_it_on_draft_gov_uk
  end

  def when_i_create_a_business_finance_support_scheme
    visit_specialist_publisher("/business-finance-support-schemes/new")

    fill_in_business_finance_support_scheme_form(title: title)

    click_button("Save as draft")
    expect_created_alert(title)
    expect(page).to have_text(/Created #{Regexp.escape(title)}/)
    expect_created_alert(title)
  end

  def then_i_can_preview_it_on_draft_gov_uk
    url = find_link("Preview draft")[:href]
    reload_url_until_status_code(url, 200)

    click_link("Preview draft")
    expect_rendering_application("draft-government-frontend")
    expect(page).to have_content(title)
  end
end
