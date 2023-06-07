#!/bin/bash

helm repo add elastic https://helm.elastic.co
helm repo update elastic

# Install Logstash
helm upgrade -i logstash elastic/logstash -f values-logstash.yaml

# Install Filebeat
helm upgrade -i filebeat elastic/filebeat -f values-filebeat.yaml
