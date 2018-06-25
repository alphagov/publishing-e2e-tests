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
    find("#asylum_support_decision_tribunal_decision_categories option:first-of-type", visible: :all).select_option
    find("#asylum_support_decision_tribunal_decision_sub_categories option:first-of-type", visible: :all).select_option
    find("#asylum_support_decision_tribunal_decision_judges option:first-of-type", visible: :all).select_option
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
    find("#business_finance_support_scheme_types_of_support option:first-of-type", visible: :all).select_option
    find("#business_finance_support_scheme_business_sizes option:first-of-type", visible: :all).select_option
    find("#business_finance_support_scheme_industries option:first-of-type", visible: :all).select_option
    find("#business_finance_support_scheme_business_stages option:first-of-type", visible: :all).select_option
    find("#business_finance_support_scheme_regions option:first-of-type", visible: :all).select_option
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
    find("#cma_case_market_sector option:first-of-type", visible: :all).select_option
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

  def fill_in_dfid_research_output_form(options = {})
    options = {
      title: unique_title,
      summary: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      first_published_at: Faker::Date.backward,
    }.merge(options)

    fill_in("Title", with: options[:title])
    fill_in("Summary", with: options[:summary])
    fill_in("Body", with: options[:body])
    find("#dfid_research_output_dfid_document_type option:nth-of-type(2)", visible: :all).select_option
    find("#dfid_research_output_dfid_theme option:first-of-type", visible: :all).select_option
    fill_in("dfid_research_output_first_published_at_year", with: options[:first_published_at].year)
    fill_in("dfid_research_output_first_published_at_month", with: options[:first_published_at].month)
    fill_in("dfid_research_output_first_published_at_day", with: options[:first_published_at].day)
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
    find("#employment_appeal_tribunal_decision_tribunal_decision_categories option:first-of-type", visible: :all).select_option
    fill_in("employment_appeal_tribunal_decision_tribunal_decision_decision_date_year", with: options[:decision_date].year)
    fill_in("employment_appeal_tribunal_decision_tribunal_decision_decision_date_month", with: options[:decision_date].month)
    fill_in("employment_appeal_tribunal_decision_tribunal_decision_decision_date_day", with: options[:decision_date].day)
  end

  def visit_specialist_publisher(path = "/")
    visit(Plek.find("specialist-publisher") + path)
  end

  def self.included(base)
    return unless SignonHelpers::use_signon?

    default_permissions = %w[editor gds_editor]

    base.before(:each) do |example|
      @user = get_next_user(
        "Specialist Publisher" =>
        example.metadata.fetch(:permissions, default_permissions),
        "Content Preview" => %w[]
      )
      signin_with_user(@user)
    end
  end
end
