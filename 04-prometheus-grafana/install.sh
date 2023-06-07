#!/bin/bash

# add the helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update prometheus-community
helm repo update grafana

# install prometheus and alertmanager
helm upgrade -i prometheus prometheus-community/prometheus -f values-prometheus.yaml

# install grafana
helm upgrade -i grafana grafana/grafana -f values-grafana.yaml
