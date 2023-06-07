#!/bin/bash

helm repo add elastic https://helm.elastic.co
helm repo update elastic

# Installing Elasticsearch
helm upgrade -i elasticsearch elastic/elasticsearch -f values-elasticsearch.yaml

# wait for Elasticsearch to come up
printf "Waiting for Elasticsearch to come up"
while [[ "$(kubectl get pods elasticsearch-master-0 -o jsonpath="{.status.phase}")" != "Running" ]]; do printf .; sleep 5; done
echo ''

# Installing Kibana
helm upgrade -i kibana elastic/kibana -f values-kibana.yaml
