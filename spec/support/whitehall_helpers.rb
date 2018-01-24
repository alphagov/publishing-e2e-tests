module WhitehallHelpers
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
