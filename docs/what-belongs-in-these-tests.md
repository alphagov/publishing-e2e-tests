# What belongs in publishing-e2e-tests

These tests are for the purpose of testing that multiple applications speak to
each other, they are done from the user perspective and, in comparison to most
forms of testing, very slow and brittle.

Thus tests should be added here to test scenarios that cannot be tested under
other means. We want this to be the tip of of the
[testing pyramid][testing-pyramid] and not an example of a
[testing ice cream cone][testing-ice-cream-cone].

Rough guidelines for our testing approach is as follows:

- A component within an application: should be unit tested
- Multiple components within an application: should be integration tested
- Applications speaking directly to each: should be
  [contract tested][contract-tested], we've used [pact][pact]
- Multiple applications communicating together: contender for end-to-end tests

eg A test here is whether Specialist Publisher can publish a document, which
involves the following apps: Specialist Publisher, Publishing API,
Content Store, Router, and Specialist Frontend. Which could not be tested under
other means.

The approach to writing tests for here is:

- Follow the conventions of existing tests here
- Aim for one scenario per file
- Only test the "happy path" behaviour, not exceptional behaviour.
- Only describe things that should *happen*, not things that shouldn't.
- Write steps to be independent, not relying on the user being on a certain
  page.
- Avoid testing negatives; these are better tested in functional/unit tests.
- Avoid testing incidental behaviour (e.g. flash messages); these are better
  tested in functional/unit tests.

This list has been adapted from
[whitehall testing guide][whitehall-testing-guide] which is worth reading
for more testing insights.

[testing-pyramid]: https://martinfowler.com/bliki/TestPyramid.html
[testing-ice-cream-cone]: http://saeedgatson.com/the-software-testing-ice-cream-cone/
[contract-tested]: https://martinfowler.com/articles/consumerDrivenContracts.html
[pact]: https://docs.pact.io/
[whitehall-testing-guide]: https://github.com/alphagov/whitehall/blob/master/docs/testing_guide.md
