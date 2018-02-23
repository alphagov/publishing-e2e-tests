feature "Creating a draft on Specialist Publisher", specialist_publisher: true, government_frontend: true do
  include SpecialistPublisherHelpers

  let(:title) { "Creating a draft Specialist Publisher #{SecureRandom.uuid}" }

  scenario "Creating a Business Finance Support Scheme" do
    when_i_create_a_business_finance_support_scheme
    then_i_can_preview_it_on_draft_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Specialist Publisher" => %w[editor gds_editor],
      "Content Preview" => [],
    )
  end

  def when_i_create_a_business_finance_support_scheme
    signin_to_signon if use_signon?
    visit_specialist_publisher("/business-finance-support-schemes/new")

    fill_in_business_finance_support_scheme_form(title: title)

    click_button("Save as draft")
    expect_created_alert(title)
    expect(page).to have_text(/Created #{Regexp.escape(title)}/)
    expect_created_alert(title)
  end

  def then_i_can_preview_it_on_draft_gov_uk
    signin_to_draft_origin(@user) if use_signon?

    url = find_link("Preview draft")[:href]
    reload_url_until_status_code(url, 200)

    click_link("Preview draft")
    expect_rendering_application("government-frontend")
    expect_url_matches_draft_gov_uk
    expect(page).to have_content(title)
  end
end
