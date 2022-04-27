pipeline {
  agent any
  stages {
    stage('build') {
      steps {
        echo "Running build in branch ${env.BRANCH_NAME}..."
        echo 'Adding new peice of code'
        }

      }
    stage('test') {
      steps {
        echo "Running test in branch ${env.BRANCH_NAME} ...."
        }

      }
    stage('Publish') {
      steps {
        withAWS(credentials:'aws-credentials', region:'ca-central-1'){
        s3Upload(bucket:"artifacts-12", includePathPattern:'**/.jar', pathStyleAccessEnabled: true, sseAlgorithm:'AES256')
          }
        }
    
      }
    }

}
