node {
    def DOCKER_IMAGE = 'virtus/david:ad_project_ihm'
    stage('Git') {
        git branch: 'main', credentialsId: 'GitlabDavid', url: 'https://gitlab.com/DLefrancq/ad_project_ihm'
    }
    stage('Build') {
        image = docker.build(
            "${DOCKER_IMAGE}",
            "-f Dockerfile .",
            "--build-arg VITE_API_URL=$VITE_API_URL"
        )
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