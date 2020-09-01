module SpecialistPublisherHelpers
  def expect_attached_alert(title)
    fail_reason = "Failed to find acknowledgement of attaching #{title} on "\
      "#{page.current_url}"
    expect(page).to have_text("Attached #{title}"), fail_reason
  end

  def expect_created_alert(title)
    fail_reason = "Failed to find acknowledgement of creating #{title} on "\
      "#{page.current_url}"
    expect(page).to have_text("Created #{title}"), fail_reason
  end

  def expect_discarded_draft_alert(title)
    fail_reason = "Failed to find acknowledgement of discarding draft "\
      "#{title} on #{page.current_url}"
    expect(page).to have_text("Discarded draft of #{title}"), fail_reason
  end

  def expect_published_alert(title)
    fail_reason = "Failed to find acknowledgement of publishing #{title} on "\
      "#{page.current_url}"
    expect(page).to have_text("Published #{title}"), fail_reason
  end

  def expect_updated_alert(title)
    fail_reason = "Failed to find acknowledgement of updating #{title} on "\
      "#{page.current_url}"
    expect(page).to have_text("Updated #{title}"), fail_reason
  end

  def expect_unpublished_alert(title)
    fail_reason = "Failed to find acknowledgement of unpublishing #{title} on "\
      "#{page.current_url}"
    expect(page).to have_text("Unpublished #{title}"), fail_reason
  end

  def fill_in_aaib_report_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      date_of_occurance: Faker::Date.backward,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    fill_in("aaib_report_date_of_occurrence_year", with: options[:date_of_occurance].year)
    fill_in("aaib_report_date_of_occurrence_month", with: options[:date_of_occurance].month)
    fill_in("aaib_report_date_of_occurrence_day", with: options[:date_of_occurance].day)
  end

  def fill_in_asylum_support_decision_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      reference_number: Faker::Number.number(10),
      decision_date: Faker::Date.backward,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    select_all_select2("asylum_support_decision_tribunal_decision_categories")
    select_all_select2("asylum_support_decision_tribunal_decision_sub_categories")
    select_all_select2("asylum_support_decision_tribunal_decision_judges")
    fill_in("Tribunal decision reference number", with: options[:reference_number])
    fill_in("asylum_support_decision_tribunal_decision_decision_date_year", with: options[:decision_date].year)
    fill_in("asylum_support_decision_tribunal_decision_decision_date_month", with: options[:decision_date].month)
    fill_in("asylum_support_decision_tribunal_decision_decision_date_day", with: options[:decision_date].day)
  end

  def fill_in_business_finance_support_scheme_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      continuation_link: Faker::Internet.url,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    fill_in("Continuation link", with: options[:continuation_link])
    select_all_select2("business_finance_support_scheme_types_of_support")
    select_all_select2("business_finance_support_scheme_business_sizes")
    select_all_select2("business_finance_support_scheme_industries")
    select_all_select2("business_finance_support_scheme_business_stages")
    select_all_select2("business_finance_support_scheme_regions")
  end

  def fill_in_cma_case_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    select_all_select2("cma_case_market_sector")
  end

  def fill_in_countryside_stewardship_grant_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
  end

  def fill_in_research_for_development_output_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      first_published_at: Faker::Date.backward,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    select2("research_for_development_output_research_document_type", "Book")
    select_all_select2("research_for_development_output_theme")
    fill_in("research_for_development_output_first_published_at_year", with: options[:first_published_at].year)
    fill_in("research_for_development_output_first_published_at_month", with: options[:first_published_at].month)
    fill_in("research_for_development_output_first_published_at_day", with: options[:first_published_at].day)
  end

  def fill_in_eat_decision_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      decision_date: Faker::Date.backward,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    select_all_select2("employment_appeal_tribunal_decision_tribunal_decision_categories")
    fill_in("employment_appeal_tribunal_decision_tribunal_decision_decision_date_year", with: options[:decision_date].year)
    fill_in("employment_appeal_tribunal_decision_tribunal_decision_decision_date_month", with: options[:decision_date].month)
    fill_in("employment_appeal_tribunal_decision_tribunal_decision_decision_date_day", with: options[:decision_date].day)
  end

  def visit_specialist_publisher(path = "/")
    visit(Plek.find("specialist-publisher") + path)
  end

  def select_all_select2(id)
    first("a[data-select-id='##{id}']").click
  end

  def select2(scope, value)
    select2_container = first("#s2id_#{scope}.select2-container")
    select2_container.click

    page.execute_script("$('##{scope}').value = '#{value}'")
    find(:xpath, "//body").first(".select2-results li", text: value).click
  end
end
