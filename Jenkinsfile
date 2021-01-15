#!/usr/bin/env groovy

library("govuk")

REPOSITORY = "publishing-e2e-tests"
DEFAULT_COMMITISH = "deployed-to-production"

def apps = [
  [constantPrefix: "ASSET_MANAGER", app: "asset-manager", name: "Asset Manager"],
  [constantPrefix: "COLLECTIONS", app: "collections", name: "Collections"],
  [constantPrefix: "COLLECTIONS_PUBLISHER", app: "collections-publisher", name: "Collections Publisher"],
  [constantPrefix: "CONTACTS_ADMIN", app: "contacts-admin", name: "Contacts Admin"],
  [constantPrefix: "CONTENT_STORE", app: "content-store", name: "Content Store"],
  [constantPrefix: "CONTENT_TAGGER", app: "content-tagger", name: "Content Tagger"],
  [constantPrefix: "EMAIL_ALERT_API", app: "email-alert-api", name: "Email Alert API"],
  [constantPrefix: "FINDER_FRONTEND", app: "finder-frontend", name: "Finder Frontend"],
  [constantPrefix: "FRONTEND", app: "frontend", name: "Frontend"],
  [constantPrefix: "GOVUK_CONTENT_SCHEMAS", app: "govuk-content-schemas", name: "GOV.UK Content Schemas"],
  [constantPrefix: "GOVERNMENT_FRONTEND", app: "government-frontend", name: "Government Frontend"],
  [constantPrefix: "MANUALS_FRONTEND", app: "manuals-frontend", name: "Manuals Frontend"],
  [constantPrefix: "MANUALS_PUBLISHER", app: "manuals-publisher", name: "Manuals Publisher"],
  [constantPrefix: "PUBLISHER", app: "publisher", name: "Publisher"],
  [constantPrefix: "PUBLISHING_API", app: "publishing-api", name: "Publishing API"],
  [constantPrefix: "ROUTER", app: "router", name: "Router"],
  [constantPrefix: "ROUTER_API", app: "router-api", name: "Router API"],
  [constantPrefix: "SEARCH_API", app: "search-api", name: "Search API"],
  [constantPrefix: "SPECIALIST_PUBLISHER", app: "specialist-publisher", name: "Specialist Publisher"],
  [constantPrefix: "STATIC", app: "static", name: "Static"],
  [constantPrefix: "TRAVEL_ADVICE_PUBLISHER", app: "travel-advice-publisher", name: "Travel Advice Publisher"],
  [constantPrefix: "WHITEHALL", app: "whitehall-admin", name: "Whitehall"],
].each { app -> app.defaultCommitish = app.defaultCommitish ?: DEFAULT_COMMITISH }

timestamps {
  node("publishing-e2e-tests") {
    initializeParameters(govuk, apps)

    originBuildStatus("Running publishing end-to-end tests on Jenkins", "PENDING", params)

    if (params.ORIGIN_REPO) {
      currentBuild.displayName = "#$BUILD_NUMBER - $ORIGIN_REPO"
    }

    lock("publishing-e2e-tests-$NODE_NAME") {
      try {
        stage("Clean workspace") {
          checkout(scm)
          sh("make -j clean_tmp clean_apps")
          cleanWs()
        }

        stage("Checkout") {
          checkout(scm)
        }

        stage("Bundle Gems") {
          govuk.bundleApp()
        }

        stage("Ruby Lint") {
          sh("bundle exec rubocop")
        }

      } catch(e) {
        failBuild(params)
        throw e
      }

      // a map to store whether tests are failed despite exception flows
      def testStatus = [flakyNewFailed: false, mainFailed: false, startUpFailed: false]

      cloneApplications(params)
      buildDockerEnvironment(params, testStatus)

      try {
        startDockerApps(testStatus)
        runFlakyNewTests(params, testStatus)
        runTests(params, testStatus)
        pushTestAgainstBranch()
        originBuildStatus("Publishing end-to-end tests succeeded on Jenkins", "SUCCESS", params)
      } catch(e) {
        failBuild(params)
        throw e
      } finally {
        makeLogsAvailable()
        alertTestOutcome(params, testStatus)

        stopDocker()

        // Docker leaves these owned by root which makes it difficult for
        // Jenkins to clean them up
        stage("Clean temporary files") {
          sh("make -j clean_tmp clean_apps")
        }
      }
    }
  }
}

def initializeParameters(govuk, appsCollection) {
  appDefaultCommits = [:]
  appParams = appsCollection.collect { app ->
    appDefaultCommits["${app.constantPrefix}_COMMITISH"] = app.defaultCommitish

    stringParam(
      defaultValue: app.defaultCommitish,
      description: "Which commit/branch/tag of ${app.name} to clone",
      name: "${app.constantPrefix}_COMMITISH"
    )
  }

  properties([
    buildDiscarder(
      logRotator(artifactDaysToKeepStr: "3", daysToKeepStr: "14", numToKeepStr: "400")
    ),
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

  unbuildableApps = [
    "govuk-content-schemas",
  ]
  appsToBuild = []
  appsCollection.each { app ->
    commitishConstant = "${app.constantPrefix}_COMMITISH"

    commitish = params[commitishConstant].trim()
    govuk.setEnvar(commitishConstant, commitish)

    if (commitish != app.defaultCommitish && !unbuildableApps.contains(app.app)) {
      appsToBuild << app.app
    }
  }

  govuk.setEnvar("APPS_TO_BUILD", appsToBuild.join(" "))
}

def originBuildStatus(message, status, params) {
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

def failBuild(params) {
  currentBuild.result = "FAILED"
  step([$class: "Mailer",
        notifyEveryUnstableBuild: true,
        recipients: "govuk-ci-notifications@digital.cabinet-office.gov.uk",
        sendToIndividuals: true])

  originBuildStatus("Publishing end-to-end tests failed on Jenkins", "FAILED", params)
}

def abortBuild(reason, params) {
  currentBuild.result = "ABORTED"
  originBuildStatus(reason, "ERROR", params)
  error(reason)
}

def cloneApplications(params) {
  stage("Clone applications") {
    try {
      sshagent(['govuk-ci-ssh-key']) {
        sh("make clone -j4")
      }
    } catch(e) {
      abortBuild("Publishing end-to-end tests could not clone all repositories", params)
    }
  }
}

def buildDockerEnvironment(params, testStatus) {
  stage("Build docker environment") {
    try {
      withCredentials([usernamePassword(credentialsId: 'govukci-docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        // --password-stdin doesn't actually improve security here but it does
        // suppress an inapplicable warning message.
        sh([
          script: 'echo $DOCKER_PASSWORD | docker login --username "$DOCKER_USERNAME" --password-stdin',
          label: 'Log into DockerHub'
        ])
      }
      sh("make pull")
      sh("make build")
    } catch(e) {
      failBuild(params)
      testStatus.startUpFailed = true
      throw e
    }
  }
}

def startDockerApps(testStatus) {
  stage("Start docker apps") {
    try {
      sh("make setup_dependencies -j12")
      sh("make up")
      sh("make setup_apps -j12")
    } catch(e) {
      echo("We weren't able to setup for tests, this probably means there is a bigger problem. Test aborting")
      testStatus.startUpFailed = true
      throw e
    }
  }
}

def runFlakyNewTests(params, testStatus) {
  echo "Running flaky/new tests that aren't in main build with `make test TEST_ARGS='--tag flaky --tag flakey --tag new'`"
  try {
    sh("make test TEST_PROCESSES=${params.TEST_PROCESSES} TEST_ARGS=\"spec -o '--tag flaky --tag flakey --tag new'\"")
  } catch(err) {
    testStatus.flakyNewFailed = true
  }
}

def runTests(params, testStatus) {
  stage("Run tests") {
    try {
      echo "Running tests with `make ${params.TEST_COMMAND}`"
      sh("make ${params.TEST_COMMAND} TEST_PROCESSES=${params.TEST_PROCESSES}")
    } catch (e) {
      testStatus.mainFailed = true
      throw e
    }
  }
}

def pushTestAgainstBranch() {
  if (env.BRANCH_NAME == "master") {
    echo 'Pushing to test-against branch'
    sshagent(['govuk-ci-ssh-key']) {
      sh("git push git@github.com:alphagov/publishing-e2e-tests.git HEAD:refs/heads/test-against --force")
    }
  }
}

def makeLogsAvailable() {
  stage("Output Error log") {
    errors = sh(script: "test -s tmp/errors.log", returnStatus: true)
    if (errors == 0) {
      echo("The following errors were logged with Sentry")
      sh("cat tmp/errors.log")
    } else {
      echo("No errors were sent to Sentry")
    }
  }

  stage("Dump docker log") {
    sh("docker-compose logs --timestamps | sort -t '|' -k 2.2,2.31 > docker.log")
  }

  stage("Archive Artifacts") {
    archiveArtifacts(artifacts: "docker.log,tmp/errors-verbose.log,tmp/screenshot*.png", fingerprint: true)
  }

  stage("JUnit") {
    def hasJUnitFiles = sh(script: "ls tmp/rspec*.xml 1> /dev/null 2>&1", returnStatus: true)
    if (hasJUnitFiles == 0) {
      junit("tmp/rspec*.xml")
    } else {
      echo("No Junit files to log")
    }
  }
}

def stopDocker() {
  stage("Stop Docker") {
    sh("make stop")
  }
}

def alertTestOutcome(params, testStatus) {
  def channel = "#govuk-e2e-tests"
  // post to slack just when it's an important branch
  if (env.BRANCH_NAME == "master" && (testStatus.mainFailed || testStatus.startUpFailed)) {
    def message = "Publishing end-to-end tests <${BUILD_URL}|failed> for master branch, changes not pushed to test-against"
    slackSend(color: "#d40100", channel: channel, message: message)
  } else if (env.BRANCH_NAME == "test-against" && testStatus.startUpFailed) {
    def message = "Publishing end-to-end tests start up <${BUILD_URL}|failed> for $NODE_NAME"
    slackSend(color: "#d40100", channel: channel, message: message)
  } else if (env.BRANCH_NAME == "test-against" && testStatus.mainFailed) {
    def message = "Publishing end-to-end tests <${BUILD_URL}|failed>"
    message += (params.ORIGIN_REPO) ? " for ${params.ORIGIN_REPO}" : ""
    slackSend(color: "#d40100", channel: channel, message: message)
  } else if (env.BRANCH_NAME == "test-against" && testStatus.flakyNewFailed) {
    def message = "Publishing end-to-end flaky/new tests <${BUILD_URL}|failed>"
    message += (params.ORIGIN_REPO) ? " for ${params.ORIGIN_REPO}" : ""
    slackSend(color: "#ffff94", channel: channel, message: message)
  }

  if (testStatus.mainFailed) {
    def guideUrl = "https://github.com/alphagov/publishing-e2e-tests/blob/master/CONTRIBUTING.md#dealing-with-flaky-tests"
    currentBuild.description = "<p style=\"color: red\">Is the failure unrelated to your change?</p>" +
                               "<p>We have <a href=\"${guideUrl}\">flaky test advice available</a> to help.</p>"
  }
}
