node {
    def registry = 'registry.gitlab.com'
    def registryProjet = 'registry.gitlab.com/mygroup4574346/myreg'
    def IMAGE_VERSION = "${registryProjet}:version-${env.BUILD_ID}"
    def IMAGE_LATEST = "${registryProjet}:latest"
    def CONTAINER_NAME = "myapp-${env.BUILD_ID}"
    def img

    stage('Clone') {
        checkout scm
    }

    stage('Build') {
        img = docker.build("${IMAGE_VERSION}", '.')
        // Taguer aussi en latest localement
        bat "docker tag ${IMAGE_VERSION} ${IMAGE_LATEST}"
    }

    stage('Run Container') {
        // Lance le conteneur en arrière-plan
        bat "docker run -d --name ${CONTAINER_NAME} -p 83:80 ${IMAGE_VERSION}"

        // Attendre que le conteneur soit prêt (ping 5 secondes)
        bat 'ping -n 6 127.0.0.1 > nul'

        // Test simple avec curl
        bat 'curl http://localhost:83'
    }

    stage('Push to Registry') {
        withCredentials([usernamePassword(
            credentialsId: 'gitlab-registry-creds',
            usernameVariable: 'GITLAB_USER',
            passwordVariable: 'GITLAB_TOKEN'
        )]) {
            bat """
                echo  Logging in to GitLab Registry...
                docker login -u %GITLAB_USER% -p %GITLAB_TOKEN% https://registry.gitlab.com

                echo  Pushing version image...
                docker push --disable-content-trust=true ${IMAGE_VERSION}

                echo  Pushing latest image...
                docker push --disable-content-trust=true ${IMAGE_LATEST}
            """
        }
    }

    stage('Clean Up') {
        // Arrête et supprime le conteneur
        bat "docker rm -f ${CONTAINER_NAME} || echo Container ${CONTAINER_NAME} does not exist."
    }
}
