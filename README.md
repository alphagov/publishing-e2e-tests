# GOV.UK Publishing End-to-end Tests

This repo is a simple set of rspec tests that can be used to perform end-to-end
testing on the GOV.UK publishing platform. In it's early infancy it is setup
just for Specialist Publisher.

To use this you need to:

- Install dependencies `bundle install`
- Run [all the applications][apps] needed for publishing with Specialist 
  Publisher
- `bundle exec rspec`

[apps]: https://github.com/alphagov/govuk-puppet/blob/6b600aa2f7a00965a41ba58513965fe556f4be5f/end-to-end-vm/set-up-apps.sh
