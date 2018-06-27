pipeline {
  agent any
  stages {
    stage('Compile') {
      steps {
        sh 'mvn clean install'
      }
    }
  }
  post {
      always {
          junit 'build/reports/**/*.xml'
      }
  }
}
