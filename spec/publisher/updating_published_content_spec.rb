feature "Updating published content from Publisher", publisher: true, frontend: true do
  include PublisherHelpers

  let(:title) { title_with_timestamp }
  let(:slug) { slug_with_timestamp }

  scenario "Scheduling downtime for a transaction on Publisher", skip: true do
    given_there_is_a_published_transaction_artefact
    when_i_schedule_downtime_for_now_on_the_transaction
    and_i_visit_the_transaction_on_gov_uk
    then_the_downtime_message_is_shown
  end

  private

  def given_there_is_a_published_transaction_artefact
    create_publisher_artefact(slug: slug, title: title)
    publish_artefact

    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end

  def when_i_schedule_downtime_for_now_on_the_transaction
    visit_publisher("/downtimes")
    click_link(title)

    date = Date.today
    fill_in_schedule_downtime_form(date)

    @downtime_message = find_field("Message").value

    click_button "Schedule downtime message"

    expect(page).to have_text(title + " downtime message scheduled")
  end

  def and_i_visit_the_transaction_on_gov_uk
    url = find_link("/" + slug)[:href]
    reload_url_until_match(url, :has_text?, @downtime_message)
    click_link("/" + slug)
  end

  def then_the_downtime_message_is_shown
    expect(page).to have_text(@downtime_message)
  end
end
