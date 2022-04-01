pipeline {
  agent any
   environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "enkengaf32/etechdevops2app:${GIT_COMMIT}"
    applicationURL = "http://etechdevops2team.eastus.cloudapp.azure.com"
    applicationURI = "/increment/99"
   }
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
    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }
   stage('SonarQube - SAST') {
      steps {
      withSonarQubeEnv('SonarQube') {
     sh '  mvn sonar:sonar \
  -Dsonar.projectKey=etechapp-token \
  -Dsonar.host.url=http://etechdevops2team.eastus.cloudapp.azure.com:9000 \
  -Dsonar.login=ee7a81739c8ac7008f18da50f129fbf914ca98c4 '
      }
         timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }
//      stage('Vulnerability Scan - Docker ') {
//       steps {
//         sh "git version"
  //}
     //}
   stage('Vulnerability Scan - Docker') {
      steps {
        parallel(
          "Dependency Scan": {
            sh "git version"
          },
          "Trivy Scan": {
            sh "bash trivy-scan.sh"
          }
        )
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
    stage('Vulnerability Scan - Kubernetes') {
      steps {
            parallel(
          "OPA Scan": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
          },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          },
          "Trivy Scan": {
            sh "bash trivy-k8s-scan.sh"
          }
        )
      }
    }
     stage('Integration Tests - DEV') {
      steps {
        script {
          try {
            withKubeConfig([credentialsId: 'jenkins-auth']) {
              sh "bash integration-test.sh"
            }
          } catch (e) {
            withKubeConfig([credentialsId: 'jenkins-auth']) {
              sh "kubectl -n default rollout undo deploy ${deploymentName}"
            }
            throw e
          }
        }
      }
    }

  }
      stage('Kubernetes Deployment - DEV') {
      steps {
         parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'jenkins-auth']) {
              sh "bash k8s-deployment.sh"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'jenkins-auth']) {
              sh "bash k8s-deployment-rollout-status.sh"
            }
          }
        )
        }
      }
    }
   post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      //dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
    }

    // success {

    // }

    // failure {

    // }
    }
}
