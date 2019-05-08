feature "Default email frequency", search_api: true, finder_frontend: true do
  context "within the Business Finder" do
    let(:signup_url) { "/find-eu-exit-guidance-business/email-signup" }
    let(:expected_option) { "daily" }

    scenario "email frequency should be daily" do
      when_i_visit signup_url
      and_i_click_create_subscription
      then_this_option_should_be_selected expected_option
    end
  end

  context "within other Finders" do
    let(:signup_url) { "/drug-device-alerts/email-signup" }
    let(:expected_option) { "immediately" }

    scenario "email frequency should be immediately" do
      when_i_visit signup_url
      and_i_click_create_subscription
      then_this_option_should_be_selected expected_option
    end
  end

private

  def when_i_visit(signup_url)
    visit "#{Plek.new.website_root}#{signup_url}"
    puts "FINDER CURRENT URL #{current_url}"
    # puts "FINDER PAGE CONTENT #{page.text}"
  end

  def and_i_click_create_subscription
    click_button "Create subscription"
    sleep 5 # allow time for page to be redirected
  end

  def then_this_option_should_be_selected(option_text)
    puts "SIGNUP CURRENT URL #{current_url}"
    # puts "SIGNUP PAGE CONTENT #{page.text}"
    expect(page.find("input[name='frequency'][value='#{option_text}']")).to be_checked
  end
end
