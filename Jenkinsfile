pipeline {
  agent any

  environment {
    DOCKERHUB_DEV_REPO = "sriramsuryaa/ecomm-app-dev"
    DOCKERHUB_PROD_REPO = "sriramsuryaa/ecomm-app-prod"
    PROD_SERVER = "${env.EC_APP_PROD}"
    DEV_SERVER  = "${env.EC_APP_DEV}"
  }

  stages {

    stage('Set Variables') {
      steps {
        script {
          echo "PROD : ${PROD_SERVER}"
          echo "DEV  : ${DEV_SERVER}" 
          def branchName = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()

          env.IMAGE_TAG = branchName == 'main' ? 'latest' : 'latest'
          env.REPO = branchName == 'main' ? env.DOCKERHUB_PROD_REPO : env.DOCKERHUB_DEV_REPO
          env.HOST = branchName == 'main' ? env.PROD_SERVER : env.DEV_SERVER


          echo "Branch: ${branchName}"
          echo "Repo: ${env.REPO}"
          echo "Tag: ${env.IMAGE_TAG}"
        }
      }
    }

    stage('Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DHUB_PASS', usernameVariable: 'DHUB_USER')]) {
        sh """ 
        docker build -t ${env.REPO}:${env.IMAGE_TAG} .
        echo \$DHUB_PASS | docker login -u \$DHUB_USER --password-stdin
        docker push ${env.REPO}:${env.IMAGE_TAG}
        """
      }
      }      
    }

    stage('Deploy to EC2') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'ecomm-app-prod', keyFileVariable: 'ECAPP_KEY', usernameVariable: 'ECAPP_USER')]) {
        sh """
        ssh -i $ECAPP_KEY -o StrictHostKeyChecking=no $ECAPP_USER@${env.HOST} '
        cd deploy/
        sudo ./deploy.sh
        '
        """
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}