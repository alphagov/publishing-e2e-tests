#!/usr/bin/env groovy

REPOSITORY = "publishing-e2e-tests"
DEFAULT_COMMITISH = "deployed-to-production"

def apps = [
  [constantPrefix: "ASSET_MANAGER", app: "asset-manager", name: "Asset Manager"],
  [constantPrefix: "CALENDARS", app: "calendars", name: "Calendars"],
  [constantPrefix: "COLLECTIONS", app: "collections", name: "Collections"],
  [constantPrefix: "COLLECTIONS_PUBLISHER", app: "collections-publisher", name: "Collections Publisher"],
  [constantPrefix: "CONTACTS_ADMIN", app: "contacts-admin", name: "Contacts Admin"],
  [constantPrefix: "CONTENT_STORE", app: "content-store", name: "Content Store"],
  [constantPrefix: "CONTENT_TAGGER", app: "content-tagger", name: "Content Tagger"],
  [constantPrefix: "FINDER_FRONTEND", app: "finder-frontend", name: "Finder Frontend"],
  [constantPrefix: "FRONTEND", app: "frontend", name: "Frontend"],
  [constantPrefix: "GOVERNMENT_FRONTEND", app: "government-frontend", name: "Government Frontend"],
  [constantPrefix: "MANUALS_FRONTEND", app: "manuals-frontend", name: "Manuals Frontend"],
  [constantPrefix: "MANUALS_PUBLISHER", app: "manuals-publisher", name: "Manuals Publisher"],
  [constantPrefix: "PUBLISHER", app: "publisher", name: "Publisher"],
  [constantPrefix: "PUBLISHING_API", app: "publishing-api", name: "Publishing API"],
  [constantPrefix: "ROUTER", app: "router", name: "Router", defaultCommitish: "master"],
  [constantPrefix: "ROUTER_API", app: "router-api", name: "Router API"],
  [constantPrefix: "RUMMAGER", app: "rummager", name: "Rummager"],
  [constantPrefix: "SPECIALIST_PUBLISHER", app: "specialist-publisher", name: "Specialist Publisher"],
  [constantPrefix: "STATIC", app: "static", name: "Static"],
  [constantPrefix: "TRAVEL_ADVICE_PUBLISHER", app: "travel-advice-publisher", name: "Travel Advice Publisher"],
  [constantPrefix: "WHITEHALL", app: "whitehall-admin", name: "Whitehall"],
].each { app -> app.defaultCommitish = app.defaultCommitish ?: DEFAULT_COMMITISH }

timestamps {
  node("publishing-e2e-tests") {

    def govuk = load("/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy")

    appDefaultCommits = [:]
    appParams = apps.collect { app ->
      appDefaultCommits["${app.constantPrefix}_COMMITISH"] = app.defaultCommitish

      stringParam(
        defaultValue: app.defaultCommitish,
        description: "Which commit/branch/tag of ${app.name} to clone",
        name: "${app.constantPrefix}_COMMITISH"
      )
    }

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
          defaultValue: "6",
          description: "Set number of processes for parallel testing",
          name: "TEST_PROCESSES"
        )
      ] + appParams)
    ])

    govuk.initializeParameters([
      "ORIGIN_REPO": "",
      "ORIGIN_COMMIT": "",
      "TEST_COMMAND": "test",
      "TEST_ARGS": "",
      "TEST_PROCESSES": "6"] + appDefaultCommits
    )

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

    appsToBuild = []
    apps.each { app ->
      commitishConstant = "${app.constantPrefix}_COMMITISH"

      commitish = params[commitishConstant].trim()
      govuk.setEnvar(commitishConstant, commitish)

      if (commitish != app.defaultCommitish) {
        appsToBuild << app.app
      }
    }

    govuk.setEnvar("APPS_TO_BUILD", appsToBuild.join(" "))

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
          sh("make clone -j4")
        }
      } catch(e) {
        abortBuild("Publishing end-to-end tests could not clone all repositories")
      }

      try {
        stage("Build docker environment") {
          sh("make pull")
          sh("make build")
        }
      } catch(e) {
        failBuild()
        throw e
      }

      try {
        stage("Start docker apps") {
          try {
            sh("make up")
            sh("make setup -j12")
          } catch(e) {
            echo("We weren't able to setup for tests, this probably means there is a bigger problem. Test aborting")
            throw e
          }
        }

        stage("Run flaky/new tests") {
          echo "Running flaky/new tests that aren't in main build with `make test TEST_ARGS='--tag flaky --tag new'`"
          try {
            sh("make test TEST_PROCESSES=${params.TEST_PROCESSES} TEST_ARGS=\"spec -o '--tag flaky --tag new'\"")
          } catch(err) {
            // Send a slack message just when tests fail within docker context
            def message = "Publishing end-to-end flaky/new tests <${BUILD_URL}|failed>"
            message += (params.ORIGIN_REPO) ? " for ${params.ORIGIN_REPO}" : ""
            slackSend(color: "#ffff94", channel: "#end-to-end-tests", message: message)
          }
        }

        stage("Run tests") {
          echo "Running tests with `make ${params.TEST_COMMAND}`"
          sh("make ${params.TEST_COMMAND} TEST_PROCESSES=${params.TEST_PROCESSES}")
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
        }

        stage("Stop Docker") {
          sh("make stop")
        }

        stage("JUnit") {
          junit 'tmp/rspec*.xml'
        }
      }
    }
  }
}
