module FrontendHelpers
  def expect_rendering_application(application)
    expect(page).to have_selector(
      "meta[name='govuk:rendering-application'][content$='#{application}']",
      visible: false,
    )
  end

  def expect_matching_uploaded_file(link, file_path)
    uploaded_file = HTTParty.get(link)
    file_contents = File.read(file_path, encoding: uploaded_file.body.encoding)
    expect(uploaded_file.body).to eq file_contents
  end

  def expect_url_matches_draft_gov_uk
    expect(current_url).to start_with(Plek.find("draft-origin"))
  end

  def expect_url_matches_live_gov_uk
    expect(current_url).to start_with(Plek.new.website_root)
  end

  RSpec.configuration.include FrontendHelpers
end
