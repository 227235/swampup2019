#!/bin/bash
# Exercise 3a - Create User and Repositories
# Reference URL -
#   REST API -  https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
#   FILESPEC - https://www.jfrog.com/confluence/display/RTF/Using+File+Specs
#   JFROG CLI - https://www.jfrog.com/confluence/display/CLI/JFrog+CLI
#   YAML Configuration - https://www.jfrog.com/confluence/display/RTF/YAML+Configuration+File
#
# Remember to update local /etc/hosts with the orbitera ip address to jfrog.local
#
# Variables
# Artifactory US (Orbitera)
ART_URL="http://jfrog.local/artifactory"
ART_PASSWORD="7I2GK045zA"
USER="admin"
ACCESS_TOKEN=""
USER_APIKEY=""
SERVER_ID="us-site"

# Artifactory EU (Orbitera)
REMOTE_ARTFACTORY="http://jfrog.local:8092/artifactory"
REMOTE_ART_ID="es-site"
REMOTE_ART_APIKEY="AKCp5aU5d6yYu3NWvMaRS99PMdU3CnHMaRD1BZXDq4padx74Gak7gnYXYNnpkQVBaLsMaw4xj"

#Dependencies
TOMCAT="tomcat-local/org/apache/apache-tomcat/apache-tomcat-*.tar.gz"
JDK="tomcat-local/java/jdk-8u91-linux-x64.tar.gz"
HELM="helm-local/helm"

# Exercise 3a - Create User and Repositories
createUser () {
  echo "Creating User: $1"
  curl  -uadmin:"${ART_PASSWORD}" -X PUT -H 'Content-Type: application/json' \
      "${ART_URL}"/api/security/users/$1 -d '{
         "name":"'"$1"'",
         "password":"'"$2"'",
         "email":"null@jfrog.com",
         "admin":true,
         "groups":["readers"]
       }'
}

getUserSecurity () {
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
       "${ART_URL}"/api/security/token -d "username=${USER}" -d "scope=member-of-groups:admin-group"))
  ACCESS_TOKEN=$(echo ${response[@]} | jq '.access_token' | sed 's/"//g')

  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST -H 'Content-Type: application/json' "${ART_URL}"/api/security/apiKey))
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X GET -H 'Content-Type: application/json' "${ART_URL}"/api/security/apiKey))
  USER_APIKEY=$(echo ${response[@]} | jq '.apiKey' | sed 's/"//g')
  echo "User api key: ${USER}:${USER_APIKEY} and access token: ${ACCESS_TOKEN}"
}

createRepo () {
  echo "Creating Repositories"
  local response=($(curl -s -u"admin":"${ART_PASSWORD}" -X PATCH -H "Content-Type: application/yaml" \
       "${ART_URL}"/api/system/configuration -T $1))
  echo ${response[@]}
}

#Exercise 3b - JFROG CLI Download
loginArt () {
   echo "Log into Artifactories"
   curl -fLs jfrog https://getcli.jfrog.io | sh
   jfrog <TBD> ${REMOTE_ART_ID} --url=${REMOTE_ARTFACTORY} --apikey=${REMOTE_ART_APIKEY}
   jfrog <TBD> ${SERVER_ID} --url=${ART_URL} --apikey=${USER_APIKEY}
   jfrog <TBD> show
}

# Download the required dependencies from remote artifactory instance (jfrogtraining)
# paths -
#    tomcat-local/org/apache/apache-tomcat/
#    tomcat-local/java/
#    generic-local/helm
# Similar to using third party binaries that are not available from remote repositories.
downloadDependencies () {
  echo "Fetch tomcat for the later docker framework build"
  jfrog <TBD> ${TOMCAT} ./tomcat/apache-tomcat-8.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=<TBD
  echo "Fetch java for the later docker framework build"
  jfrog <TBD> ${JDK} ./jdk/jdk-8-linux-x64.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=<TBD>
  echo "Fetch Helm Client for later helm chart"
  jfrog <TBD> ${HELM} ./ --server-id ${REMOTE_ART_ID} --props=<TBD>
}

main () {
#   createUser "swampupdev2019" "9YF*9@UT4Ca^CDeF"
#   createUser "swampupops2019" "9YF*9@UT4Ca^CDeF"
#   createRepo "/Users/stanleyf/git/swampup2019/su-116-advance-automation/module3/repo.yaml"
#   getUserSecurity
   loginArt
   downloadDependencies
}

main
