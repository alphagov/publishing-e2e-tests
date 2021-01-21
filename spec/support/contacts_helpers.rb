module ContactsHelpers
  def publish_contact(title:)
    visit(Plek.find("contacts-admin") + "/admin/contacts/new")
    fill_in "contact_title", with: title
    fill_in "Description", with: sentence
    select2("HM Revenue & Customs [HMRC]", from: "Organisation")
    click_button "Create Contact"
  end

  def search_for_contact(title:)
    fill_in "contacts_search_q", with: title
    click_button "Filter contacts"
  end
end
