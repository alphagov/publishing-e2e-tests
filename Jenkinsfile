#!/usr/bin/env groovy

REPOSITORY = "publishing-e2e-tests"

node("docker") {
  properties([
    parameters([
      stringParam(
        defaultValue: "master",
        description: "Which commit/branch/tag of publishing-api to clone",
        name: "PUBLISHING_API_COMMITISH"
      )
    ])
  ])

  lock("publishing-e2e-tests-$NODE_NAME") {
    try {
      stage("Checkout") {
        checkout scm
      }


      stage("Build") {
        withEnv(["PUBLISHING_API_COMMITISH=${params.PUBLISHING_API_COMMITISH}"]) {
          sh("make clone -j4")
          sh("make build")
          sh("make start")
          sh("make test")
          sh("make stop")
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
      sh("make stop")
    }
  }
}
