pipeline{
    agent any
    tools{
        jdk "jdk-17"
        maven "Maven3"
    }
    stages{
        stage("build the jar"){
            steps{
                echo "build the jar.... "
                sh "mvn package"
            }
        }
        stage("build the image "){
            steps{
                echo "building the image...."
                withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                sh "docker build -t thedevopsrookie/test-app:jma-3.0 ."
                sh "echo $PASS | docker login -u $USER --password-stdin"
                sh "docker push thedevopsrookie/test-app:jma-3.0"
                }
            }
        }
        stage("deploy the image to docekr hub"){
            steps{
                echo "deploying the image.... "
            }
        }
    }
}