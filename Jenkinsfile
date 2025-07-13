pipeline{
    agent any
    tools{
        jdk "jdk-17"
        maven "Maven3"
    }
    environment{
          DOCKER_BUILDKIT = '1'
    }
    stages{
        stage("increment app version"){
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
            steps{
                echo "build the jar.... "
                sh "mvn clean package"
                sh "ls -lah target/"
            }
        }
        stage("build the image "){
            steps{
                echo "building the image...."
                withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                sh '''echo "$PASS" | docker login -u "$USER" --password-stdin'''
                sh "docker buildx build --load -t thedevopsrookie/test-app:${IMAGE_NAME} ."
                }
            }
        }
        stage("deploy the image to docker hub"){
            steps{
                echo "deploying the image.... "
                sh "docker push thedevopsrookie/test-app:${IMAGE_NAME}"

            }
        }
        stage("commit version update"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'gitlab-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                       // sh 'git config user.email "souidi.nassim94@gmail.com"'
                        //sh 'git config user.name "nassim"'
                        sh 'git status'
                        sh 'git branch'
                        sh 'git config --list'
                        sh "git remote set-url origin https://${USER}:${PASS}@gitlab.com/naswd/java-maven-app.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump (update pom.xml version)"'
                        sh 'git push origin HEAD:master'
                    }
                }

            }
        }
    }
}