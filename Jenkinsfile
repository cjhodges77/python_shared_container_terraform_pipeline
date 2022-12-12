final REGISTRY = "***********.dkr.ecr.eu-west-2.amazonaws.com"

node(label: 'docker') {

    try {
        stage('Checkout') {
            step([$class: 'WsCleanup'])
            checkout scm
        }

        stage('Prepare build environment') {
            sh """
            make buildx-prepare JOB_NAME=$env.JOB_BASE_NAME
            aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $REGISTRY
            """
        }

        stage('Build and Push Test Images') {
            sh """
            make buildx-build-release-base TAG=test
            aws ecr batch-delete-image --repository-name aws-lambda-release-base --image-ids imageTag=test
            make buildx-push-release-base TAG=test

            make buildx-build-dev-base TAG=test
            aws ecr batch-delete-image --repository-name aws-lambda-dev-base --image-ids imageTag=test
            make buildx-push-dev-base TAG=test
        """
        }

        stage('Build and test example project using local buildLambda') {
            final testBuildLambda = load "${pwd()}/vars/buildLambda.groovy"
            testBuildLambda.call(
                base_image_tag: "test",
                directory: "example-project",
                repo_name: "aws-lambda-example-project"
            )
        }

        if (env.BRANCH_NAME == "main") {
            stage('Build and Push Latest Images') {
                sh """
            aws ecr batch-delete-image --repository-name aws-lambda-release-base --image-ids imageTag=latest
            make buildx-push-release-base TAG=latest

            aws ecr batch-delete-image --repository-name aws-lambda-dev-base --image-ids imageTag=latest
            make buildx-push-dev-base TAG=latest
        """
            }
        }

    } catch (exc) {

        if (env.BRANCH_NAME == 'main') {
            snsPublish topicArn: 'arn:aws:sns:eu-west-2:************:jenkins_build_notifications',
                subject: env.JOB_NAME,
                message: 'Failed',
                messageAttributes: [
                    'BUILD_URL': env.BUILD_URL
                ]
        }
        throw exc

    } finally {

        sh "make buildx-clean JOB_NAME=$env.JOB_BASE_NAME"

    }

}
