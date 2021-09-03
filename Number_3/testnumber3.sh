import jenkins.model.*
import hudson.security.*

echo "Installation Jenkins"
    docker run -p 8090:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk11


echo "Installation ElasticSearch"
    docker pull docker.elastic.co/elasticsearch/elasticsearch:7.5.2

echo "Installation Kibana"
    docker network create elastic
    docker pull docker.elastic.co/elasticsearch/elasticsearch:7.14.1
    docker run --name es01-test --net elastic -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.14.1
    docker pull docker.elastic.co/kibana/kibana:7.14.1
    docker run --name kib01-test --net elastic -p 5601:5601 -e "ELASTICSEARCH_HOSTS=http://es01-test:9200" docker.elastic.co/kibana/kibana:7.14.1

echo "Skip Jenkins Setup Wizard"
    ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false


echo "Admin user Setup"
    def env = System.getenv()

    def jenkins = Jenkins.getInstance()
    if(!(jenkins.getSecurityRealm() instanceof HudsonPrivateSecurityRealm))
        jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))

    if(!(jenkins.getAuthorizationStrategy() instanceof GlobalMatrixAuthorizationStrategy))
        jenkins.setAuthorizationStrategy(new GlobalMatrixAuthorizationStrategy())

    def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_USER, env.JENKINS_PASS)
    user.save()
    jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_USER)

    jenkins.save()

echo "Installation Jenkins Plugin Kubernetes and SafeRestart"
    COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
    RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt