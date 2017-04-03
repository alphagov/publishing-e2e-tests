module FrontendHelpers
  def expect_rendering_application(application)
    expect(page).to have_selector(
      "meta[name='govuk:rendering-application'][content='#{application}']",
      visible: false
    )
  end

  def expect_matching_uploaded_file(link, file_path)
    uploaded_file = HTTParty.get(link)
    file_contents = File.read(file_path, encoding: uploaded_file.body.encoding)
    expect(uploaded_file.body).to eq file_contents
  end

  RSpec.configuration.include FrontendHelpers
end
