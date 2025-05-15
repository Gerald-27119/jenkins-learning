pipeline {
    agent any

    environment {
        TARGET_DIR = 'target'
        CLASS_DIR  = "${TARGET_DIR}/classes"
        TEST_DIR   = "${TARGET_DIR}/test-classes"
        REPORT_DIR = "${TARGET_DIR}/reports"
        // Jeśli nadal potrzebujesz jakiegoś API_KEY, to odkomentuj:
        // API_KEY    = credentials('api-key-id')
    }

    options {
        timestamps()
    }

    stage('Debug') {
        steps {
            script {
                def branchName = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                echo "The current branch name is: ${branchName}"
            }
        }
    }

    stages {
        stage('Checkout') {
            steps {
                // publiczne repo → po prostu klonuje to, co podałeś w konfiguracji joba
                checkout scm
            }
        }

        stage('Validation') {
            steps {
                script {
                    for (d in ['src/main/java','src/test/java','lib']) {
                        if (!fileExists(d)) {
                            error("‼️ Brak katalogu ${d}")
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                sh """
                  mkdir -p ${CLASS_DIR} ${TEST_DIR} ${REPORT_DIR}
                  javac -d ${CLASS_DIR} -cp "lib/*" \$(find src/main/java -name '*.java')
                  javac -d ${TEST_DIR}  -cp "${CLASS_DIR}:lib/*" \$(find src/test/java  -name '*.java')
                """
                stash name: 'build-artifacts', includes: "${CLASS_DIR}/**/*.class,${TEST_DIR}/**/*.class,lib/**/*.jar"
            }
        }

       stage('Test') {
         steps {
           unstash 'build-artifacts'
           // DOPISZ to:
           sh 'echo "Zawartość lib:" && ls -l lib'
           script {
             try {
               sh """
                 java -jar lib/junit-platform-console-standalone-*.jar \
                   --class-path ${CLASS_DIR}:${TEST_DIR}:lib/* \
                   --scan-class-path \
                   --reports-dir=${REPORT_DIR}
               """
             } finally {
               junit testResults: "${REPORT_DIR}/**/*.xml", allowEmptyResults: true
             }
           }
         }
       }

        stage('Package') {
            when { branch 'master' }
            steps {
                sh "jar cf app-${BUILD_ID}.jar -C ${CLASS_DIR} ."
            }
        }

        stage('Archive') {
            when { branch 'master' }
            steps {
                archiveArtifacts artifacts: "app-${BUILD_ID}.jar,${REPORT_DIR}/**/*.xml", fingerprint: true
            }
        }
    }

    post {
        always {
            echo "🔥 Pipeline zakończony (status: ${currentBuild.currentResult})"
        }
    }
}
