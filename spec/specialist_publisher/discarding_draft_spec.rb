feature "Discarding a draft on Specialist Publisher", specialist_publisher: true, government_frontend: true do
  include SpecialistPublisherHelpers

  let(:title) { "Discarding a draft Specialist Publisher #{SecureRandom.uuid}" }

  scenario "Discarding a draft CMA case" do
    given_there_is_a_draft_cma_case
    when_i_discard_it
    then_i_get_a_404_on_draft_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Specialist Publisher" => %w[editor gds_editor],
      "Content Preview" => [],
    )
  end

  def given_there_is_a_draft_cma_case
    signin_to_signon if use_signon?
    visit_specialist_publisher("/cma-cases/new")

    fill_in_cma_case_form(title: title)

    click_button("Save as draft")
    expect_created_alert(title)
  end

  def when_i_discard_it
    signin_to_draft_origin(@user) if use_signon?

    @url = find_link("Preview draft")[:href]
    expect_status_code_eventually(@url, 200, keep_retrying_while: 404)

    page.accept_confirm do
      click_button("Discard draft")
    end

    expect_discarded_draft_alert(title)
  end

  def then_i_get_a_404_on_draft_gov_uk
    expect_status_code_eventually(@url, 404, keep_retrying_while: 200)

    visit(@url)
    expect_url_matches_draft_gov_uk
  end
end
