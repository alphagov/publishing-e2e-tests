# Writing tests

> **Warning: this repo is DEPRECATED as of [RFC 128 (Continuous Deployment)](https://github.com/alphagov/govuk-rfcs/blob/main/rfc-128-continuous-deployment.md#delete-publishing-e2e-tests)**. The tests are slow and brittle and do not run in a realistic GOV.UK environment. Do not add any new tests to this repo.
>
> Instead of adding a test here, you can add a [smoke test](https://github.com/alphagov/smokey) for the publishing action in real GOV.UK environments. See the Smokey docs for guidance about writing this kind of "mutating state" test.

## What belongs here

This repo contains tests for critical publishing actions and their impact on the draft or live site. For example, publishing a document and checking it's visible on GOV.UK.

Do not add tests that can be implemented in other ways. We want this to be the tip of of the [testing pyramid][testing-pyramid], not a [testing ice cream cone][testing-ice-cream-cone]. Instead of adding a test here, you can:

- Add or extend [health checks for application infrastructure](https://github.com/alphagov/govuk_app_config/blob/main/docs/healthchecks.md). For example, drafting a document in a publishing app involves connecting to infrastructure like a database or AWS S3.

- Add [contract tests](https://docs.publishing.service.gov.uk/manual/pact-broker.html) to cover the chain of APIs in a publishing action. For example, publishing a document involves Publishing API, Email Alert API, Content Store and Router.

- Add unit or integration tests to cover in-app behaviour. For example, the way each document format is rendered can be tested in the frontend app that does the rendering.

In contrast, the tests in this repo provide coverage at a higher level. They check that the chain of state changes in a publishing action culminate in a change on the draft or live site.

## Adding new tests

The feature tests are written in a style consistent with this article:
[How we write readable feature tests with rspec][readable-feature-tests].

Tests should be tagged to the publishing and rendering applications they are testing using [rspec tags][] to only run tests that concern that application e.g. `feature "Some feature", whitehall: true`.

Use `new: true` when adding a new test, until it has been run for a sufficiently long period for you to be confident it is not flakey. Tests that are tagged with `new` will not fail the overall build.

Rules to follow for new tests:

- Aim for one scenario per file.
- Test what _should_ happen, not what shouldn't.
- Test critical functionality, not superficial behaviour e.g. flash messages.

Some tips for writing tests:

- Starting up the docker containers is _slow_. Use `binding.pry` to pry into your test and use the console to debug and write your test. Additionally, `save_screenshot('filename.png')` will help you see what is going on.

- If you are relying on code in a repo, ensure that the code is in the `deployed-to-production` branch. If not, see main README for guidance on running the tests against a different branch.

[rspec tags]: https://relishapp.com/rspec/rspec-core/v/3-7/docs/command-line/tag-option
[readable-feature-tests]: https://about.futurelearn.com/blog/how-we-write-readable-feature-tests-with-rspec
[testing-pyramid]: https://martinfowler.com/bliki/TestPyramid.html
[testing-ice-cream-cone]: http://saeedgatson.com/the-software-testing-ice-cream-cone/
