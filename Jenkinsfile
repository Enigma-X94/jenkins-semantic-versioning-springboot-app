pipeline{
    agent any
    tools{
        jdk "jdk-17"
        maven "Maven3"
    }
    stages{
        stage("increment app version"){
            steps{
                echo "ncrement app version...."
                sh ''' mvn build-helper:parse-version version:set \
                DnewVersion=${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion}\
                versions:commit'''

                def newVersion= sh(
                    script:'mvn help:evaluate - Dexpression=project.version -DforceStdout',
                    returnStdout: true
                ).trim()

                echo "Maven Project Version: ${version}"

                IMAGE_NAME= "${newVersion}.${BUILD.NUMBER}"
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
                sh "echo $PASS | docker login -u $USER --password-stdin"
                sh "docker build -t thedevopsrookie/test-app:${IMAGE_NAME} ."
                }
            }
        }
        stage("deploy the image to docker hub"){
            steps{
                echo "deploying the image.... "
                sh "docker push thedevopsrookie/test-app:${IMAGE_NAME}"

            }
        }
        /*stage("commit version update"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'g', passwordVariable: 'PASS', usernameVariable: 'USER')]) {

                }

            }
        }*/
    }
}