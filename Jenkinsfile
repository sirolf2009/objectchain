pipeline {
  agent any
  stages {
    stage('Compile') {
      steps {
        sh 'mvn clean install'
      }
    }
    stage('Archive Test Results') {
      steps {
        junit 'target/surefire-reports/*.xml'
      }
    }
  }
}