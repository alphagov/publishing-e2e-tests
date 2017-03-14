#!/usr/bin/env groovy

REPOSITORY = "publishing-e2e-tests"

node("docker") {
  properties([
    parameters([
      stringParam(
        defaultValue: "master",
        description: "Which branch/commit/tag of publishing-api to clone",
        name: "PUBLISHING_API_BRANCH"
      )
    ])
  ])

  try {
    stage("Checkout") {
      checkout scm
    }

    stage("Build") {
      withEnv(["PUBLISHING_API_BRANCH=${params.PUBLISHING_API_BRANCH}"]) {
        dir("${WORKSPACE}") {
          sh "make clone -j4"
          sh "make build"
          sh "make start"
          sh "make test"
          sh "make stop"
        }
      }
    }
  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: "Mailer",
          notifyEveryUnstableBuild: true,
          recipients: "govuk-ci-notifications@digital.cabinet-office.gov.uk",
          sendToIndividuals: true])
    throw e
  } finally {
    dir("${WORKSPACE}") {
      sh "make stop"
    }
  }
}
