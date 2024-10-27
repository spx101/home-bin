#!/bin/bash

# https://confluence.atlassian.com/bamkb/unable-to-publish-specs-or-create-maven-project-due-to-pkix-error-1082262959.html

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# apt update && apt -y install ssh

JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64/"
# JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

KEYSTORE="$JAVA_HOME/jre/lib/security/cacerts"

HOST=bamboo.grupa.onet
PORT=443

# lista certyfikatow
# keytool -keystore $KEYSTORE -storepass changeit -list

openssl s_client -connect $HOST:$PORT < /dev/null |
	sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' |
	keytool -noprompt -import -v -trustcacerts -alias $HOST \
 		-keystore $KEYSTORE \
		-keypass changeit -storepass changeit

# usuniecie certyfikatu
# keytool -delete -alias $HOST -keystore $KEYSTORE -storepass changeit



