#!/usr/bin/env groovy

def call(Map parameters = [:]) {

    final ALL_ACCOUNTS = [
        integration  : "************",
        staging      : "************",
        qa           : "************",
        externaltest : "************",
        production   : "************",
        development  : "************",
    ]
    final DIRECTORY = parameters.getOrDefault("directory", "")
    final REGISTRY = "**********.dkr.ecr.eu-west-2.amazonaws.com"
    final BASE_IMAGE_TAG = parameters.getOrDefault("base_image_tag", "latest")
    final DEV_IMAGE_URI = "$REGISTRY/aws-lambda-dev-base:$BASE_IMAGE_TAG"
    final RELEASE_IMAGE_URI = "$REGISTRY/aws-lambda-release-base:$BASE_IMAGE_TAG"

    pipeline {
        agent {
            label 'docker'
        }

        options {
            timestamps()
            ansiColor 'xterm'
        }

        environment {
            GIT_TAG = sh(returnStdout: true, script: 'git describe --dirty=_WIP --always').trim()
            BUILD_TIME = sh(returnStdout: true, script: 'date +%Y%m%d%H%M%S').trim()
            IMAGE_TAG = "${env.GIT_TAG}-${env.BUILD_TIME}"
            IMAGE_URI = "$REGISTRY/$parameters.repo_name:${env.IMAGE_TAG}"
            WORKDIR = "${env.WORKSPACE}/$DIRECTORY"
        }

        stages {
            stage("Pull dev container") {
                steps {
                    sh """
                        aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $REGISTRY
                        docker pull $DEV_IMAGE_URI
                     """
                }
            }

            stage("Override base container tag") {
                steps {
                   dir("${env.WORKDIR}") {
                        sh "sed -i 's/:latest/:$BASE_IMAGE_TAG/g' Dockerfile"
                        }
                }
            }

            stage("Check container base images") {
                steps {
                    dir("$env.WORKDIR") {
                        sh """
                            grep -q "$DEV_IMAGE_URI" Dockerfile
                            grep -q "$RELEASE_IMAGE_URI" Dockerfile
                        """
                    }
                }
            }

            stage("Build container") {
                    steps {
                        dir("$env.WORKDIR") {
                            sh "make build TAG=${env.IMAGE_URI}"
                    }
                }
            }

            stage("Run linting tests") {
                steps {
                    dir("$env.WORKDIR") {
                        sh "make test-lint"
                    }
                }
            }

            stage("Run tests") {
                steps {
                    dir("$env.WORKDIR") {
                        sh "make test"
                    }
                }
            }

            stage("Security test container") {
                steps {
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${env.IMAGE_URI}"
                }
            }

            stage("Push image to ECR and update SSM parameter") {
                steps {
                    script {
                        if (env.BRANCH_NAME == "main") {
                            sh """
                                docker push ${env.IMAGE_URI}
                                docker inspect --format='{{index .RepoDigests 0}}' ${env.IMAGE_URI} > digest.txt
                            """

                            archiveArtifacts 'digest.txt'

                            ALL_ACCOUNTS.each { account -> sh("""
                                set +x
                                SESSIONID=\$(date +"%s")
                                AWS_CREDENTIALS=\$(aws sts assume-role --role-arn arn:aws:iam::${account.value}:role/service/RoleJenkinsTerraformProvisioner --role-session-name \$SESSIONID --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' --output text)
                                export AWS_ACCESS_KEY_ID=\$(echo \$AWS_CREDENTIALS | awk '{print \$1}')
                                export AWS_SECRET_ACCESS_KEY=\$(echo \$AWS_CREDENTIALS | awk '{print \$2}')
                                export AWS_SESSION_TOKEN=\$(echo \$AWS_CREDENTIALS | awk '{print \$3}')
                                aws ssm put-parameter --name /ecr/latest-images/${parameters.repo_name}/${env.BRANCH_NAME} --value ${env.IMAGE_TAG} --type String --overwrite
                            """)}
                        } else {
                            sh 'echo Not the main branch, skipping'
                        }
                    }
                }
            }
        }

        post {
            failure {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        snsPublish topicArn: 'arn:aws:sns:eu-west-2:************:jenkins_build_notifications',
                            subject: env.JOB_NAME,
                            message: 'Failed',
                            messageAttributes: [
                                'BUILD_URL': env.BUILD_URL
                            ]
                    }
                }
            }
        }
    }
}

return this
