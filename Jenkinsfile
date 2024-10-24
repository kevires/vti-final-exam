pipeline {
    agent any
    
      environment {
        ACCESS_KEY = credentials('AWS_ACCESS_KEY_ID') 
        SECRET_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Deploy fe') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], gitTool: 'Default', userRemoteConfigs: [[credentialsId: '8d3a8116-8c26-417a-a0ef-1d20e7790115', url: 'https://github.com/kevires/vti-final-exam.git']])            
                sh 'ls -la /var/lib/jenkins/workspace/vti-pipeline/'
                sh 'aws s3 cp /var/lib/jenkins/workspace/vti-pipeline/fe/index.html s3://khainh-static-website.com'
            }
        }
        
        stage('Deploy be') {
            steps {
                script {
                     sh '''
                        mkdir -p ~/.aws
                        echo "[default]" > ~/.aws/credentials
                        echo "aws_access_key_id = ${ACCESS_KEY}" >> ~/.aws/credentials
                        echo "aws_secret_access_key = ${SECRET_KEY}" >> ~/.aws/credentials
                        echo "[default]" > ~/.aws/config
                        echo "region = ap-southeast-1" >> ~/.aws/config
                    '''
                    sh 'docker login -u AWS -p $(aws ecr get-login-password --region ap-southeast-1) 084375555299.dkr.ecr.ap-southeast-1.amazonaws.com'
                    sh 'docker build -f /var/lib/jenkins/workspace/vti-pipeline/be/Dockerfile -t 084375555299.dkr.ecr.ap-southeast-1.amazonaws.com/vti/khainh-repo:latest /var/lib/jenkins/workspace/vti-pipeline/be'
                    sh 'docker push 084375555299.dkr.ecr.ap-southeast-1.amazonaws.com/vti/khainh-repo:latest'
                    sh 'aws eks --region ap-southeast-1 update-kubeconfig --name khainheks'
                    sh 'kubectl delete deployment flask-app'
                    sh 'kubectl apply -f /var/lib/jenkins/workspace/vti-pipeline/tf/deployment.yaml'
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