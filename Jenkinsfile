def skipBuild = false
pipeline{
    agent any
    tools{
        jdk "jdk-17"
        maven "Maven3"
    }
    environment{
          DOCKER_BUILDKIT = '1'
          SKIP_BUILD = "false"
    }
    stages{
        stage("checking for ci skip"){
            steps{
                script{
                    def lastCommitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    def lastCommiter =  sh(script: "git log -1 --pretty=%ae",returnStdout: true).trim()

                    if(lastCommitMsg.contains('[ci skip]') && lastCommiter == 'jenkins@EnigmaPC.localdomain'){
                        echo "Build triggered by CI version bump commit. Skipping build."
                        currentBuild.description = 'skipped by [ci skip]'
                        skipBuild =true
                        echo"******************************************"
                        echo "skipBuild value is now: ${skipBuild}"
                        echo"******************************************"
                    }
                }
            }
        }
        stage("increment app version"){
            when{
                expression{
                    return !skipBuild
                }
            }
            steps{
                script{
                echo "ncrement app version...."
                sh ''' mvn build-helper:parse-version versions:set \
                -DnewVersion='${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion}'\
                versions:commit'''

                def newVersion= sh(
                    script:'mvn help:evaluate -Dexpression=project.version -q -DforceStdout',
                    returnStdout: true
                ).trim()

                echo "Maven Project Version: ${newVersion}"

                env.IMAGE_NAME= "${newVersion}.${env.BUILD_NUMBER}"
                }
            }
        }
        stage("build the jar"){
            when{
                expression{
                  return !skipBuild
                }
            }
            steps{
                echo "build the jar.... "
                sh "mvn clean package"
                sh "ls -lah target/"
            }
        }
        stage("build the image "){
            when{
                expression{
                    env.SKIP_BUILD != "true"
                }
            }
            steps{
                echo "building the image...."
                withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                sh '''echo "$PASS" | docker login -u "$USER" --password-stdin'''
                sh "docker buildx build --load -t thedevopsrookie/test-app:${IMAGE_NAME} ."
                }
            }
        }
        stage("deploy the image to docker hub"){
            when{
                expression{
                    return !skipBuild
                }
            }
            steps{
                echo "deploying the image.... "
                sh "docker push thedevopsrookie/test-app:${IMAGE_NAME}"

            }
        }
        stage("commit version update"){
            when{
                expression{
                   return !skipBuild
                }
            }
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'gitlab-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "git config user.email 'jenkins@EnigmaPC.localdomain'"
                        sh "git config user.name 'Jenkins'"
                        sh "git remote set-url origin https://${USER}:${PASS}@gitlab.com/naswd/java-maven-app.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump (update pom.xml version) [ci skip]" || echo "No changes to commit"'
                        sh 'git push origin HEAD:master'
                    }
                }

            }
        }
    }
}