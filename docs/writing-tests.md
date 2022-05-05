# Writing tests

This guide covers the basics for contributing to this project.

- [Coding style](#coding-style)
- [Adding new tests](#adding-new-tests)

## Coding style

The feature tests are written in a style consistent with this article:
[How we write readable feature tests with rspec][readable-feature-tests].

[readable-feature-tests]: https://about.futurelearn.com/blog/how-we-write-readable-feature-tests-with-rspec

## Adding new tests

New tests that are added should be providing coverage of flows that touch more
than 2 applications in the GOV.UK stack. Further guidance can be found in
[what-belongs-in-these-tests.md](docs/what-belongs-in-these-tests.md).

Tests should be tagged to the publishing and rendering applications they are
testing using [rspec tags][] to only run tests that concern that application.

Use `new: true` when adding a new test, until it has been run for a sufficiently long period for you to be confident it is not flakey. Tests that are tagged with `new` will not fail the overall build.

### Tips
- Starting up the docker containers is _slow_. Use `binding.pry` to pry into your test and use the console to debug and write your test. Additionally, `save_screenshot('filename.png')` will help you see what is going on.
- If you are relying on code in a repo, ensure that the code is in the `deployed-to-production` branch. If not, see main README for guidance on running the tests against a different branch.

[rspec tags]: https://relishapp.com/rspec/rspec-core/v/3-7/docs/command-line/tag-option
