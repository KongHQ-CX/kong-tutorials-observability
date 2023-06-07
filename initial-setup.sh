#!/bin/bash

if [ -z "$1" ]
then
  echo ''
  echo 'Usage:'
  echo '         ./initial-setup.sh my.ingress.domain.local'
  echo ''
  
  exit 1
fi

export INGRESS_DOMAIN=$1

# Set all ingress domains across all Helm values
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 01-base-kong/values-control-plane.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 01-base-kong/values-data-plane.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 02-base-elastic-stack/values-elasticsearch.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 02-base-elastic-stack/values-kibana.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 03-logstash-filebeat/values-filebeat.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 03-logstash-filebeat/values-logstash.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 04-prometheus-grafana/values-grafana.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 04-prometheus-grafana/values-prometheus.yaml
sed -i.bak "s/INGRESS_DOMAIN/$INGRESS_DOMAIN/g" 05-opentelemetry/values-jaegeraio.yaml
