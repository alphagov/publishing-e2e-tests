module WhitehallHelpers
  def create_consultation(title:)
    visit(Plek.find("whitehall-admin") + "/government/admin/consultations/new")
    fill_in_consultation_form(title: title)
    click_button("Save and continue")
    expect(page).to have_text("The document has been saved")
    check "Test taxon", allow_label_click: true
    click_button("Update and review specialist topic tags")
    expect(page).to have_text("The tags have been updated")
    click_button("Save")
    expect(page).to have_text("The associations have been saved")
  end

  def fill_in_consultation_form(title:, body: paragraph_with_timestamp)
    fill_in "Title", with: title
    fill_in "Summary", with: sentence
    fill_in "Body", with: body
    fill_in_opening_date(Date.today)
    fill_in_closing_date(Date.today.next_year)
    select_from_chosen "Test Policy Area", id: "edition_topic_ids"
    check "Applies to all UK nations"
    check id: "edition_read_consultation_principles"
  end

  def force_publish_document
    click_link("Force publish")
    fill_in "Reason for force publishing", with: "End to end test"
    click_button("Force publish")
    expect(page).to have_text("has been published")
  end

  def fill_in_opening_date(date)
    select(date.year, from: "edition_opening_at_1i")
    select(Date::MONTHNAMES[date.month], from: "edition_opening_at_2i")
    select(date.day, from: "edition_opening_at_3i")
  end

  def fill_in_closing_date(date)
    select(date.year, from: "edition_closing_at_1i")
    select(Date::MONTHNAMES[date.month], from: "edition_closing_at_2i")
    select(date.day, from: "edition_closing_at_3i")
  end

  # Whitehall makes use of a JS library called chosen to improve its select boxes
  # https://harvesthq.github.io/chosen/
  # This code was evolved from the gist at https://gist.github.com/thijsc/1391107
  def select_from_chosen(item_text, options)
    option_value = page.evaluate_script("$(\"##{options[:id]} option:contains('#{item_text}')\").val()")
    page.execute_script("$('##{options[:id]}').val('#{option_value}')")
  end
end
