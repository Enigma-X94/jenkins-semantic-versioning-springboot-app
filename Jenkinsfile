def skipBuild = false
pipeline{
    agent any
    tools{
        jdk "jdk-17"
        maven "Maven3"
    }
    environment{
          DOCKER_BUILDKIT = '1'
          DOCKER_REGISTRY = 'thedevopsrookie'
          APP_NAME= 'test'
    }
    stages{
        stage("Checking for ci skip"){
            steps{
                script{
                    def lastCommitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    def lastCommiter =  sh(script: "git log -1 --pretty=%ae",returnStdout: true).trim()
                    echo "=== Commit Information ==="
                    echo "Last commit message: ${lastCommitMsg}"
                    echo "Last committer: ${lastCommiter}"

                    def skipPatternsList = ['[ci skip]', '[skip ci]']

                    def mustSkip = skipPatternsList.any {pattern -> lastCommitMsg.toLowerCase().contains(pattern.toLowerCase())}


                    if(mustSkip){
                        echo "Skip Marker is found in commit message !!! Skipping build."
                        currentBuild.description = 'skipped by Skip Marker'
                        currentBuild.result ='NOT_BUILT'
                        skipBuild =true
                    }else{
                         echo "Skip Markers not found !!! Proceeding with build."
                    }
                }
            }
        }
        stage("Increment app version"){
            when{
                expression{
                    return !skipBuild
                }
            }
            steps{
                script{
                    echo "Incrementing app version...."
                    try{
                    sh ''' mvn build-helper:parse-version versions:set \
                    -DnewVersion='${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion}'\
                    versions:commit'''

                    def newVersion= sh(
                        script:'mvn help:evaluate -Dexpression=project.version -q -DforceStdout',
                        returnStdout: true
                    ).trim()

                    if(!newVersion){
                        error "Failed to retrieve maven version"
                    }

                    echo "Maven Project New Version: ${newVersion}"
                    env.IMAGE_NAME = "${newVersion}-${env.BUILD_NUMBER}"
                    env.IMAGE_TAG = "${DOCKER_REGISTRY}/${APP_NAME}:${env.IMAGE_NAME}"

                    currentBuild.description = "VERSION: ${newVersion}"

                    
                    }catch(Exception){

                    }
                }
                
            }
        }
        stage("Build the jar"){
            when{
                expression{
                  return !skipBuild
                }
            }
            steps{
                echo "Build the JAR FILE.... "
                sh "mvn clean package"
                script{
                    def jarExists = sh(script: "ls target/*.jar 2>/dev/null | wc -l", returnStdout : true).trim()
                    if(jarExists == 0 ){
                        error "JAR FILE not found in target directory"

                    }
                    sh "ls -lah target/"
                }
            }
        }
        stage("Build the image "){
            when{
                expression{
                    return !skipBuild
                }
            }
            steps{
                echo "Building the image...."
                withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                sh '''echo "$PASS" | docker login -u "$USER" --password-stdin'''
                sh "docker buildx build --load -t ${env.IMAGE_TAG} ."
                sh "docker images | grep ${APP_NAME}"
                }
            }
        }
        stage("Push the image to docker hub"){
            when{
                expression{
                    return !skipBuild
                }
            }
            steps{
                echo "Pushing the image to docker registry.... "
                sh "docker push  ${env.IMAGE_TAG}"

            }
        }
        stage("Commit version update"){
            when{
                expression{
                   return !skipBuild
                }
            }
            steps{
                echo "Committing version update ..."
                script{
                    withCredentials([usernamePassword(credentialsId: 'gitlab-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "git config user.email 'jenkins@EnigmaPC.localdomain'"
                        sh "git config user.name 'Jenkins'"
                        sh "git remote set-url origin https://${USER}:${PASS}@gitlab.com/naswd/java-maven-app.git"
                        
                        def changes = sh(
                            script: 'git status --porcelain',
                            returnStdout: true
                        ).trim()

                        if(changes){
                            sh ''' 
                            git add pom.xml
                            git commit -m "[ci skip] Automated version bump
                            - Updated project version
                            - Build: ${BUILD_NUMBER}
                            - Triggered by: ${BUILD_URL}"
                            '''
                        sh 'git push origin HEAD:master'
                        echo "Version update commited and pushed"
                        }else{
                            echo "No changes to commit"
                        }
                    }
                }

            }
        }
    }
    post{
        always {
            // Clean workspace
            cleanWs()
            
            // Logout from Docker
            sh 'docker logout || true'
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
        notBuilt {
            echo "Pipeline was skipped"
        }
    }
}
