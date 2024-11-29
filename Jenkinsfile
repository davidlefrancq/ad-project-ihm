node {
    def DOCKER_IMAGE = 'virtus/david:ad_project_ihm'
    stage('Git') {
        git branch: 'main', credentialsId: 'GitlabDavid', url: 'https://gitlab.com/DLefrancq/ad_project_ihm'
    }
    stage('Build') {
        withCredentials([string(credentialsId: 'VITE_API_URL', variable: 'VITE_API_URL')]) {
            sh """
                docker build \
                --build-arg VITE_API_URL=${VITE_API_URL} \
                -t ${DOCKER_IMAGE} \
                -f Dockerfile .
            """
        }
        sh 'docker images'
    }
    stage('Deploy') {
        sh 'docker login -u virtus -p $DOCKER_PASSWORD'
        sh "docker push ${DOCKER_IMAGE}"
    }
    stage('Clean') {
        sh "docker rmi ${DOCKER_IMAGE}"
        sh 'docker images'
    }
    stage('Depmloiment CD') {
        ansiblePlaybook(credentialsId: 'test', inventory: 'ansible/inventories/hosts', playbook: 'cdihm.yml')
    }
}