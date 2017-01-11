module SpecialistPublisherAssertionHelpers
  def expect_title(title)
    reload_page_while_failing do
      within(".govuk-title") do
        expect(page).to have_content(title)
      end
    end
  end

  def expect_change_note(change_note)
    reload_page_while_failing do
      click_link("+ full page history")
      within("#full-history") do
        expect(page).to have_content(change_note)
      end
    end
  end

  def expect_rendering_app_meta
    reload_page_while_failing do
      expect(page).to have_selector(
        "meta[name='govuk:rendering-application'][content='specialist-frontend']",
        visible: false
      )
    end
  end

  def expect_error(message)
    within(".elements-error-summary") do
      expect(page).to have_content(message)
    end
  end

  def expect_unpublished
    expect(find(".alert").text).to match(/^Unpublished/)
  end

  RSpec.configuration.include SpecialistPublisherAssertionHelpers
end
