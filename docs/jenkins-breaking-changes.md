# Getting a breaking app change through Jenkins

This guide describes the scenario where you are changing the behaviour of an
application, and the E2E tests require changes to get the tests passing
against your change.

1. Create a PR on the publishing-e2e-tests which makes the E2E tests pass when
   run against the updated version of your application(s). The
   [how to run the tests guide][how-to-run-tests] explains how to perform this
   on your development machine.

2. Once your test works locally you’ll want to get both your application and E2E
   tests repo changes passing the GitHub CI checks.

   1. Go to the [publishing-e2e-tests project on Jenkins][jenkins-job] and click
      through into your branch with the updated tests.

   2. Using the “Build with Parameters” option on the left hand bar replace the
      following parameters.

      `${YOUR_APP_NAME}_COMMITTISH` with the commit SHA of your change

      `ORIGIN_REPO` with your application repo name, e.g. government-frontend

      `ORIGIN_COMMIT` with the same commit SHA as above

      Publishing E2E tests uses the `ORIGIN_REPO` + `ORIGIN_COMMIT` when pushing
      the GitHub status, and the `_COMMITTISH` to know which version of each app
      to test against.

   3.  Hit the Build button

3. Merge your application changes as you would normally.  Unless your change to
   E2E tests is compatible with the old version of your application, don’t
   merge your change to E2E tests at this stage.

4. Deploy your application change to production
      - for manually deployed apps, as you would normally do;
      - for continuously deployed apps, repeat step 2. ii. by selecting the
      previous build and clicking “Rebuild”
      
   Wait for deployed-to-production to be updated.

5. Merge your E2E tests change into main branch. This will trigger the
   main build which also updates the test-against branch.  Once test-against
   branch is updated any subsequent test runs will use both your updated tests
   and your updated application code on deployed-to-production.

If you are making significant changes to any of the tests, it is recommended you
treat the test as though it were new and attach the new tag as per the
[Adding new tests guidance][adding-new-tests-guidance]

[how-to-run-tests]: ./README.md#how-to-run-the-tests
[jenkins-job]: https://ci.integration.publishing.service.gov.uk/job/publishing-e2e-tests/
[adding-new-tests-guidance]: ./CONTRIBUTING.md#adding-new-tests
