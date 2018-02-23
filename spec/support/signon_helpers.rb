# coding: utf-8

require 'rotp'

module SignonHelpers
  class User
    attr_reader :email, :passphrase, :number

    @next_user_number = 1

    def initialize(superuser: false)
      @number = superuser ? 0 : User.get_next_user_number

      if @number >= User.available_user_count
        raise "Only #{User.available_user_count} available"
      end

      @email = ENV.fetch("SIGNON_USER_#{@number}_EMAIL")
      @passphrase = ENV.fetch("SIGNON_USER_#{@number}_PASSPHRASE")
    end

    def two_step_verification_code
      ROTP::TOTP.new(two_step_verification_secret).now
    end

    # Save the secret, so that the tests can be rerun
    def two_step_verification_secret_file_name
      "tmp/user_#{number}_two_step_verification_secret"
    end

    def two_step_verification_secret=(secret)
      File.open(two_step_verification_secret_file_name, 'w') do |f|
        f.puts secret
      end
    end

    def two_step_verification_secret
      @_two_step_verification_secret ||=
        File.open(two_step_verification_secret_file_name, &:readline).strip
    end

    def self.get_next_user_number
      number = @next_user_number
      @next_user_number += 1
      number
    end

    def self.reset_next_user_number
      @next_user_number = 1
    end

    def self.available_user_count
      count = ENV['SIGNON_USER_COUNT']
      count.nil? ? nil : count.to_i
    end

    def self.superuser
      @_superuser ||= User.new(superuser: true)
    end
  end

  def get_next_user(permissions = {})
    user = User.new

    signin_with_user(User.superuser)
    set_user_permissions(user.email, permissions)

    user
  end

  def use_signon?
    !User::available_user_count.nil?
  end

  def signin_with_user(user)
    visit_signon('/users/sign_in') unless
      has_current_path?("#{signon_url}/users/signin")

    # If some user is already signed in
    if current_path == '/'
      # TODO: Checking if the right user is already signed in at this
      # point would be ideal, but for now, sign out, so that we can
      # sign in.
      first(:link, 'Sign out').click
    end

    fill_in('Email', with: user.email)
    fill_in('Passphrase', with: user.passphrase)
    click_button('Sign in')

    if current_path == '/users/two_step_verification/prompt'
      click_link('Start set up')
      click_link('Next')

      paragraph = find('p', text: 'Enter the code manually:')

      user.two_step_verification_secret = paragraph.text.split(' ').last

      click_link('Next')

      fill_in(
        'Code from your phone',
        with: user.two_step_verification_code
      )

      click_button('submit_code')
    elsif current_path == '/users/two_step_verification/session/new'
      fill_in(
        'Verification code',
        with: user.two_step_verification_code
      )

      click_button('Sign in')
    end

    if current_path == '/'
      return true
    else
      raise "Couldn't sign in to Signon, current path is #{current_path}"
    end
  end

  def set_user_permissions(email, app_permissions)
    return if app_permissions.empty?

    visit_signon('/users')
    fill_in('Name or email', with: email)
    click_button('Search')

    within('td', text: email) do
      find('a').click
    end

    within_table('editable-permissions') do
      app_permissions.each do |app, permissions|
        within(:xpath, "//tr[td//text()[normalize-space(.) ='#{app}']]") do
          find("input[type='checkbox']").set(!permissions.nil?)

          options = all('option', visible: :all)

          if permissions.include? 'signin'
            raise "The 'signin' permission is implicit, so it doesn't need to be included"
          end

          supported_permissions = options.map { |o| o.text(:all) }
          unsupported_permissions =
            permissions - supported_permissions

          unless unsupported_permissions.empty?
            raise "#{app} does not support the #{unsupported_permissions} permissions, only #{supported_permissions}"
          end

          options.each do |option|
            if permissions.include?(option.text(:all))
              option.select_option
            else
              option.unselect_option
            end
          end
        end
      end
    end

    click_button('Update User')
  end

  def visit_signon(path = '/')
    visit(signon_url + path)
  end

  def signon_url
    @_signon_url ||= Plek.find('signon')
  end

  def self.included(base)
    base.after(:each) do
      User::reset_next_user_number
    end
  end

  RSpec.configuration.include SignonHelpers
end
