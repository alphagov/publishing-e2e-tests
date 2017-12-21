#!/usr/bin/env groovy

REPOSITORY = "publishing-e2e-tests"
DEFAULT_COMMITISH = "deployed-to-production"

timestamps {
  node("publishing-e2e-tests") {

    def govuk = load("/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy")

    properties([
      [$class: "BuildDiscarderProperty",
       strategy: [$class: "LogRotator",
                  artifactDaysToKeepStr: "",
                  artifactDaysToKeepStr: "",
                  daysToKeepStr: "30",
                  numToKeepStr: ""]],
      parameters([
        stringParam(
          defaultValue: "",
          description: "Which repo (if any) triggered this build. eg publishing-api",
          name: "ORIGIN_REPO"
        ),
        stringParam(
          defaultValue: "",
          description: "The full SHA1 hash of the commit from ORIGIN_REPO which triggered this build",
          name: "ORIGIN_COMMIT"
        ),
        stringParam(
          defaultValue: "test",
          description: "The command used to initiate tests, defaults to 'test' which tests all apps",
          name: "TEST_COMMAND"
        ),
        stringParam(
          defaultValue: "",
          description: "Allows for overriding the default arguments following rspec such as the path to spec or spec directory used to focus on the test(s), useful for flaky tests.",
          name: "TEST_ARGS"
        ),
        stringParam(
          defaultValue: "2",
          description: "Set number of processes for parallel testing",
          name: "TEST_PROCESSES"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of asset-manager to clone",
          name: "ASSET_MANAGER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of content-store to clone",
          name: "CONTENT_STORE_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of government-frontend to clone",
          name: "GOVERNMENT_FRONTEND_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of publishing-api to clone",
          name: "PUBLISHING_API_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of router-api to clone",
          name: "ROUTER_API_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of rummager to clone",
          name: "RUMMAGER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of specialist-publisher to clone",
          name: "SPECIALIST_PUBLISHER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of static to clone",
          name: "STATIC_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of travel-advice-publisher to clone",
          name: "TRAVEL_ADVICE_PUBLISHER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of collections-publisher to clone",
          name: "COLLECTIONS_PUBLISHER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of collections to clone",
          name: "COLLECTIONS_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of publisher to clone",
          name: "PUBLISHER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of frontend to clone",
          name: "FRONTEND_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of calendars to clone",
          name: "CALENDARS_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of manuals-publisher to clone",
          name: "MANUALS_PUBLISHER_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of manuals-frontend to clone",
          name: "MANUALS_FRONTEND_COMMITISH"
        ),
        stringParam(
          defaultValue: DEFAULT_COMMITISH,
          description: "Which commit/branch/tag of whitehall to clone",
          name: "WHITEHALL_COMMITISH"
        ),
      ])
    ])

    govuk.initializeParameters([
      "ORIGIN_REPO": "",
      "ORIGIN_COMMIT": "",
      "TEST_COMMAND": "test",
      "TEST_ARGS": "",
      "TEST_PROCESSES": "3",
      "ASSET_MANAGER_COMMITISH": DEFAULT_COMMITISH,
      "CONTENT_STORE_COMMITISH": DEFAULT_COMMITISH,
      "GOVERNMENT_FRONTEND_COMMITISH": DEFAULT_COMMITISH,
      "PUBLISHING_API_COMMITISH": DEFAULT_COMMITISH,
      "ROUTER_API_COMMITISH": DEFAULT_COMMITISH,
      "RUMMAGER_COMMITISH": DEFAULT_COMMITISH,
      "SPECIALIST_PUBLISHER_COMMITISH": DEFAULT_COMMITISH,
      "STATIC_COMMITISH": DEFAULT_COMMITISH,
      "TRAVEL_ADVICE_PUBLISHER_COMMITISH": DEFAULT_COMMITISH,
      "COLLECTIONS_PUBLISHER_COMMITISH": DEFAULT_COMMITISH,
      "COLLECTIONS_COMMITISH": DEFAULT_COMMITISH,
      "PUBLISHER_COMMITISH": DEFAULT_COMMITISH,
      "FRONTEND_COMMITISH": DEFAULT_COMMITISH,
      "CALENDARS_COMMITISH": DEFAULT_COMMITISH,
      "MANUALS_PUBLISHER_COMMITISH": DEFAULT_COMMITISH,
      "MANUALS_FRONTEND_COMMITISH": DEFAULT_COMMITISH,
      "WHITEHALL_COMMITISH": DEFAULT_COMMITISH,
    ])

    def originBuildStatus = { message, status ->
      if (params.ORIGIN_REPO && params.ORIGIN_COMMIT) {
        step([
            $class: "GitHubCommitStatusSetter",
            commitShaSource: [$class: "ManuallyEnteredShaSource", sha: params.ORIGIN_COMMIT],
            reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/alphagov/${params.ORIGIN_REPO}"],
            contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "continuous-integration/jenkins/publishing-e2e-tests"],
            errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
            statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: status]] ]
        ]);
      }
    }

    def failBuild = {
      currentBuild.result = "FAILED"
      step([$class: "Mailer",
            notifyEveryUnstableBuild: true,
            recipients: "govuk-ci-notifications@digital.cabinet-office.gov.uk",
            sendToIndividuals: true])

      originBuildStatus("Publishing end-to-end tests failed on Jenkins", "FAILED")
    }

    def abortBuild = { reason ->
       currentBuild.result = "ABORTED"
       originBuildStatus(reason, "ERROR")
       error(reason)
    }

    lock("publishing-e2e-tests-$NODE_NAME") {
      try {
        originBuildStatus("Running publishing end-to-end tests on Jenkins", "PENDING")

        stage("Checkout") {
          checkout(scm)
        }

        stage("Bundle Gems") {
          govuk.bundleApp()
        }

        stage("Ruby Lint") {
          govuk.rubyLinter("spec lib")
        }

      } catch(e) {
        failBuild()
        throw e
      }

      try {
        stage("Clone applications") {
          withEnv([
            "ASSET_MANAGER_COMMITISH=${params.ASSET_MANAGER_COMMITISH}",
            "CONTENT_STORE_COMMITISH=${params.CONTENT_STORE_COMMITISH}",
            "GOVERNMENT_FRONTEND_COMMITISH=${params.GOVERNMENT_FRONTEND_COMMITISH}",
            "PUBLISHING_API_COMMITISH=${params.PUBLISHING_API_COMMITISH}",
            "ROUTER_API_COMMITISH=${params.ROUTER_API_COMMITISH}",
            "RUMMAGER_COMMITISH=${params.RUMMAGER_COMMITISH}",
            "SPECIALIST_PUBLISHER_COMMITISH=${params.SPECIALIST_PUBLISHER_COMMITISH}",
            "STATIC_COMMITISH=${params.STATIC_COMMITISH}",
            "TRAVEL_ADVICE_PUBLISHER_COMMITISH=${params.TRAVEL_ADVICE_PUBLISHER_COMMITISH}",
            "COLLECTIONS_PUBLISHER_COMMITISH=${params.COLLECTIONS_PUBLISHER_COMMITISH}",
            "COLLECTIONS_COMMITISH=${params.COLLECTIONS_COMMITISH}",
            "PUBLISHER_COMMITISH=${params.PUBLISHER_COMMITISH}",
            "FRONTEND_COMMITISH=${params.FRONTEND_COMMITISH}",
            "CALENDARS_COMMITISH=${params.CALENDARS_COMMITISH}",
            "MANUALS_PUBLISHER_COMMITISH=${params.MANUALS_PUBLISHER_COMMITISH}",
            "MANUALS_FRONTEND_COMMITISH=${params.MANUALS_FRONTEND_COMMITISH}",
            "WHITEHALL_COMMITISH=${params.WHITEHALL_COMMITISH}",
          ]) {
            sh("make clone -j4")
          }
        }
      } catch(e) {
        abortBuild("Publishing end-to-end tests could not clone all repositories")
      }

      try {
        stage("Build docker environment") {
          sh("make build")
        }

        stage("Start docker apps") {
          try {
            sh("make start")
          } catch(e) {
            echo("We weren't able to setup for tests, this probably means there is a bigger problem. Test aborting")
            throw e
          }
        }

        stage("Run tests") {
          echo "Running tests with `make ${params.TEST_COMMAND}`"
          sh("make ${params.TEST_COMMAND}")
        }

        stage("Run flaky/new tests") {
          echo "Running flaky/new tests that aren't in main build with `make test TEST_ARGS='--tag flaky --tag new'`"
          try {
            sh("make test TEST_ARGS=\"spec -o '--tag flaky --tag new'\"")
          } catch(err) {
            // Send a slack message just when tests fail within docker context
            def message = "Publishing end-to-end flaky/new tests <${BUILD_URL}|failed>"
            message += (params.ORIGIN_REPO) ? " for ${params.ORIGIN_REPO}" : ""
            slackSend(color: "#ffff94", channel: "#end-to-end-tests", message: message)
          }
        }

        if (env.BRANCH_NAME == "master") {
          echo 'Pushing to test-against branch'
          sshagent(['govuk-ci-ssh-key']) {
            sh("git push git@github.com:alphagov/publishing-e2e-tests.git HEAD:refs/heads/test-against --force")
          }
        }

        originBuildStatus("Publishing end-to-end tests succeeded on Jenkins", "SUCCESS")

      } catch (e) {
        failBuild()

        echo("Did this fail due to a flaky test? See: https://github.com/alphagov/publishing-e2e-tests/blob/master/CONTRIBUTING.md")
        // Send a slack message just when tests fail within docker context
        def message = "Publishing end-to-end tests <${BUILD_URL}|failed>"
        message += (params.ORIGIN_REPO) ? " for ${params.ORIGIN_REPO}" : ""
        slackSend(color: "#d40100", channel: "#end-to-end-tests", message: message)

        throw e
      } finally {
        stage("Make logs available") {
          errors = sh(script: "test -s tmp/errors.log", returnStatus: true)
          if (errors == 0) {
            echo("The following errors were logged with sentry/errbit:")
            sh("cat tmp/errors.log")
          } else {
            echo("No errors were sent to sentry/errbit")
          }

          echo("dumping docker log")
          sh("docker-compose logs --timestamps | sort -t '|' -k 2.2,2.31 > docker.log")

          archiveArtifacts(artifacts: "docker.log,tmp/errors-verbose.log,tmp/screenshot*.png", fingerprint: true)
          junit 'tmp/rspec*.xml'
        }

        stage("Stop Docker") {
          sh("make stop")
        }
      }
    }
  }
}
