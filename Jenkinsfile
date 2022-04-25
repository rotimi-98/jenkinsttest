pipeline {
  agent none
  stages {
    stage('worker-build') {
      agent {
        docker {
          image 'maven:3.8.1-adoptopenjdk-11'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      when {
        allOf {
          changeset '**/worker/**'
        }

      }
      steps {
        echo 'Compiling worker application...'
        dir(path: 'worker') {
          sh 'mvn compile'
        }

      }
    }

    stage('worker-test') {
      agent {
        docker {
          image 'maven:3.8.1-adoptopenjdk-11'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      when {
        allOf {
          changeset '**/worker/**'
        }

      }
      steps {
        echo 'Running unit test for worker application..'
        dir(path: 'worker') {
          sh 'mvn compile && mvn clean test'
        }

      }
    }

    stage('worker-docker-package') {
      agent any
      when {
        allOf {
          branch 'master'
          changeset '**/worker/**'
        }

      }
      steps {
        echo 'Packaging worker application...with Docker'
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerlogin') {
            def workerImage = docker.build("rotimi98/worker:v${env.BUILD_ID}", "./worker")
            workerImage.push()
            workerImage.push("${env.BRANCH_NAME}")
          }
        }

      }
    }

    stage('result-build') {
      agent {
        docker {
          image 'node:16.13.1-alpine'
        }

      }
      when {
        allOf {
          changeset '**/result/**'
        }

      }
      steps {
        echo 'Compiling worker application...'
        dir(path: 'result') {
          sh 'npm install'
        }

      }
    }

    stage('result-test') {
      agent {
        docker {
          image 'node:16.13.1-alpine'
        }

      }
      when {
        allOf {
          changeset '**/result/**'
        }

      }
      steps {
        echo 'Running unit test for worker application..'
        dir(path: 'result') {
          sh 'npm install && npm test'
        }

      }
    }

    stage('result-package') {
      agent {
        docker {
          image 'node:16.13.1-alpine'
        }

      }
      when {
        allOf {
          branch 'master'
          changeset '**/result/**'
        }

      }
      steps {
        echo 'Packaging and archiving result application...'
        dir(path: 'result') {
          sh 'npm install && npm test'
          sh '''
                     #!/bin/bash
                     if test -e result_*.tar.gz; then
                     rm result_*.tar.gz
                     fi
                  '''
          sh 'tar czf result_$BUILD_NUMBER.tar.gz node_modules server.js package.json Dockerfile Dockerfile-scratch'
          archiveArtifacts(artifacts: 'result_*.tar.gz', fingerprint: true)
        }

      }
    }

    stage('result-docker-package') {
      agent any
      when {
        allOf {
          branch 'master'
          changeset '**/result/**'
        }

      }
      steps {
        echo 'Packaging and archiving result application...'
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerlogin'){
            def resultImage = docker.build("rotimi98/result:v${env.BUILD_ID}", "./result")
            resultImage.push()
            resultImage.push("${env.BRANCH_NAME}")
          }
        }

      }
    }

    stage('vote-build') {
      agent {
        docker {
          image 'python:2.7.16-slim'
          args '--user root'
        }

      }
      when {
        allOf {
          changeset '**/vote/**'
        }

      }
      steps {
        echo 'Compiling worker application...'
        dir(path: 'vote') {
          sh 'pip install -r requirements.txt'
        }

      }
    }

    stage('vote-test') {
      agent {
        docker {
          image 'python:2.7.16-slim'
          args '--user root'
        }

      }
      when {
        allOf {
          changeset '**/vote/**'
        }

      }
      steps {
        echo 'Running unit test for vote application..'
        dir(path: 'vote') {
          sh 'pip install -r requirements.txt'
          sh 'nosetests -v'
        }

      }
    }

    stage('vote-integration-test') {
      agent any
      when {
        allOf {
          branch 'master'
          changeset '**/vote/**'
        }

      }
      steps {
        echo 'Running Integration test on vote application...'
        dir(path: 'vote') {
        /*  sh 'integration_test.sh' */
                      sh '''
                            #!/bin/bash

		            cd integration

		            echo "I: creating environment to run integration tests..."

		            docker-compose build
		            docker-compose up -d

		            echo "I: Launching Integration Test..."

		            docker-compose run --rm integration /test/tests.sh

			    if [ $? -eq 0 ]
			    then
  			      echo "----------------------------------"
  			      echo "Integration Tests Passed......"
  			      echo "----------------------------------"
  			      docker-compose down
  			      cd ..
  			      exit 0
			    else
  			      echo "----------------------------------"
  			      echo "Integration Tests Failed......"
  			      echo "----------------------------------"
  			      docker-compose down
  			      cd ..
  			      exit 1
		       	    fi
                         '''
        }

      }
    }

    stage('vote-docker-package') {
      agent any
      when {
        allOf {
          branch 'master'
          changeset '**/vote/**'
        }

      }
      steps {
        echo 'Running unit test for worker application..'
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerlogin') {
            def voteImage = docker.build("rotimi98/vote:v${env.BUILD_ID}", "./vote")
            voteImage.push()
            voteImage.push("${env.BRANCH_NAME}")
          }
        }

      }
    }

    stage('end-to-end test') {
      agent any
      when {
        allOf {
          branch 'master'
        }

      }
      steps {
        echo 'Running end-to-end test on all application...'
        dir(path: '.') {
        /*  sh 'integration_test.sh' */
                      sh '''
                                #!/bin/bash

                                cd e2e

                                #docker-compose down

                                #sleep 10

                                docker-compose build
                                docker-compose up -d

                                docker-compose ps


                                sleep 15

                                #docker-compose run --rm e2e
                                docker-compose run --rm e2e

                                docker-compose down
                         '''
        }

      }
    }

    stage('Sonarqube') {
      agent any
/*      when{
        branch 'master'
      }
*/
      tools {
        jdk "JDK11" // the name you have given the JDK installation in Global Tool Configuration
      }

      environment{
        sonarpath = tool 'SonarScanner'
      }

      steps {
            echo 'Running Sonarqube Analysis..'
            withSonarQubeEnv('sonar-instavote') {
              sh "${sonarpath}/bin/sonar-scanner -Dproject.settings=sonar-project.properties -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=86400"
            }
      }
    }

    stage("Quality Gate") {
        steps {
            timeout(time: 2, unit: 'MINUTES') {
                // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                // true = set pipeline to UNSTABLE, false = don't
                waitForQualityGate abortPipeline: true
            }

        }
    }

    stage('Deploy to Dev') {
      agent any
      when {
        allOf {
          branch 'master'
        }
      }
      steps {
        sh 'docker-compose up -d'
      }
    }

  }
  post {
    always {
      echo 'Pipeline for vote is completed and packaging archive file...'
    }

    failure {
      slackSend(channel: '#vote', message: "Build failed ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
    }

    success {
      slackSend(channel: '#vote', message: "Build succeeded ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
    }

  }
}
