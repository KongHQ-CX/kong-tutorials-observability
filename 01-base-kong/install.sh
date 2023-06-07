#!/bin/bash
if [ -z "$1" ]
then
  echo "USAGE: ./install.sh .domain.tld"
else
  if ! deck > /dev/null 2>&1
  then
    echo "Install the latest Kong 'deck' CLI tool - follow instructions: https://github.com/Kong/deck#installation"
  else
    echo "Using cookie domain ${1}"
    # setup
    kubectl create namespace kong
    kubectl config set-context --current --namespace kong

    # install echo server
    kubectl apply -f echo-server-otlp.yaml

    if ! kubectl get secret kong-cluster-cert > /dev/null 2>&1
    then
      # generate cluster cert and install
      openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) \
        -keyout cluster.key -out cluster.crt \
        -days 1095 -subj "/CN=kong_clustering"
      kubectl create secret tls kong-cluster-cert --cert=cluster.crt --key=cluster.key --dry-run=client -o yaml | kubectl apply -f -
      rm -f ./cluster.*
    fi

    # generate superuser password and install
    kubectl create secret generic kong-enterprise-superuser-password --from-literal=password=K1ngK0ng --dry-run=client -o yaml | kubectl apply -f -

    # generate session conf and install
    echo "{\"cookie_name\":\"admin_session\",\"cookie_samesite\":\"off\",\"cookie_domain\":\"${1}\",\"secret\":\"admin-secret-CHANGEME\",\"cookie_secure\":true,\"storage\":\"kong\"}" > admin_gui_session_conf
    echo "{\"cookie_name\":\"portal;_session\",\"cookie_samesite\":\"off\",\"cookie_domain\":\"${1}\",\"secret\":\"portal-secret-CHANGEME\",\"cookie_secure\":true,\"storage\":\"kong\"}" > portal_session_conf
    kubectl create secret generic kong-session-config --from-file=admin_gui_session_conf --from-file=portal_session_conf --dry-run=client -o yaml | kubectl apply -f -
    rm -f admin_gui_session_conf portal_session_conf

    # install license
    kubectl create secret generic kong-enterprise-license --from-file=license=$HOME/.license/kong.json --dry-run=client -o yaml | kubectl apply -f -

    helm repo add kong https://charts.konghq.com
    helm repo update kong

    helm upgrade -i kongcp kong/kong -f values-control-plane.yaml --version=2.14.0
    helm upgrade -i kongdp kong/kong -f values-data-plane.yaml --version=2.14.0

    # wait for kong to come up
    printf "Waiting for Kong Admin to come up"
    while [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' https://kong-admin.${1}})" != "401" ]]; do printf .; sleep 2; done
    echo ''

    # apply configuration
    echo 'Applying initial Kong deck configuration'
    deck --tls-skip-verify --kong-addr="https://kong-admin.${1}" --headers="kong-admin-token:K1ngK0ng" sync -s initial-kong.yaml
  fi
fi
