#!/bin/bash

helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade -i jaeger jaegertracing/jaeger -f values-jaegeraio.yaml
