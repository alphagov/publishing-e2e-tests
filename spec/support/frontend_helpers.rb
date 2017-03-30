module FrontendHelpers
  def expect_rendering_application(application)
    expect(page).to have_selector(
      "meta[name='govuk:rendering-application'][content='#{application}']",
      visible: false
    )
  end

  RSpec.configuration.include FrontendHelpers
end
