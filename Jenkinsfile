pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://3.145.201.220:9000'
        APP_NAME      = 'registrationform'
        DOCKER_IMAGE  = 'satwik0731/registrationform'
        VERSION       = "${env.BUILD_NUMBER}"
        MAVEN_PROJECT_DIR = ''
        SKIP_MAVEN = 'true'
    }

    tools {
        maven 'maven3'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Maven Project') {
            steps {
                script {
                    def pomPath = sh(
                        script: "find . -name pom.xml | head -n 1",
                        returnStdout: true
                    ).trim()

                    if (pomPath) {
                        env.MAVEN_PROJECT_DIR = pomPath.replace('/pom.xml', '')
                        env.SKIP_MAVEN = 'false'
                        echo "✅ Maven project detected at: ${env.MAVEN_PROJECT_DIR}"
                    } else {
                        env.SKIP_MAVEN = 'true'
                        echo "⚠️ No pom.xml found — Maven, Sonar & Nexus stages will be skipped"
                    }
                }
            }
        }

        stage('Build & Test') {
            when {
                expression { env.SKIP_MAVEN == 'false' }
            }
            steps {
                dir("${MAVEN_PROJECT_DIR}") {
                    sh 'mvn clean package'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: "${MAVEN_PROJECT_DIR}/**/target/surefire-reports/*.xml"
                }
            }
        }

        stage('SonarQube Analysis') {
            when {
                expression { env.SKIP_MAVEN == 'false' }
            }
            steps {
                dir("${MAVEN_PROJECT_DIR}") {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                            mvn sonar:sonar \
                            -Dsonar.projectKey=${APP_NAME} \
                            -Dsonar.host.url=${SONARQUBE_URL} \
                            -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        stage('Upload to Nexus (Snapshots)') {
            when {
                expression { env.SKIP_MAVEN == 'false' }
            }
            steps {
                dir("${MAVEN_PROJECT_DIR}") {
                    withCredentials([usernamePassword(
                        credentialsId: 'nexus-creds',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )]) {
                        sh """
cat <<EOF > settings.xml
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
  </servers>
</settings>
EOF
                        """
                        sh 'mvn deploy -DskipTests -s settings.xml'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${VERSION} ."
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh """
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${VERSION}
                        docker tag ${DOCKER_IMAGE}:${VERSION} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to Docker Host (via Ansible)') {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@18.216.107.250 \
                    'cd ~/ansible && ansible-playbook -i inventory.ini deploy-app.yml'
                """
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
        always {
            cleanWs()
        }
    }
}
