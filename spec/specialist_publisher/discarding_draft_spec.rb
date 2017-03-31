feature "Discarding a draft on Specialist Publisher", specialist_publisher: true do
  include SpecialistPublisherHelpers

  let(:title) { title_with_timestamp }

  scenario "Discarding a draft CMA case" do
    given_there_is_a_draft_cma_case
    when_i_discard_it
    then_i_get_a_404_on_draft_gov_uk
  end

  def given_there_is_a_draft_cma_case
    visit_specialist_publisher("/cma-cases/new")

    fill_in_cma_case_form(title: title)

    click_button("Save as draft")
    expect_created_alert(title)
  end

  def when_i_discard_it
    @url = find_link("Preview draft")[:href]

    page.accept_confirm do
      click_button("Discard draft")
    end

    expect_discarded_draft_alert(title)
  end

  def then_i_get_a_404_on_draft_gov_uk
    reload_url_until_status_code(@url, 404, keep_retrying_while: [200, 503])

    visit(@url)
    expect(page).to have_text("not found")
  end
end
