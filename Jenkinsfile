pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
              sh "git version"
              sh " git version"
            }
        }
       stage('Unit Tests - JUnit and Jacoco') {
      steps {
        sh "mvn test"
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
    }
      stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "dockerhub-id", url: ""]) {
          sh 'printenv'
          sh 'docker build -t enkengaf32/etechdevops2app:""$GIT_COMMIT"" .'
          sh 'docker push enkengaf32/etechdevops2app:""$GIT_COMMIT""'
        }
      }
    }
    }
}
