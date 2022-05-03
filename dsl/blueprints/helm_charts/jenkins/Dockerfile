FROM jenkins/jenkins:lts

RUN jenkins-plugin-cli --plugins \
    kubernetes \
    workflow-aggregator \
    git \
    configuration-as-code \
    github \
    blueocean \
    job-dsl \
    ldap
