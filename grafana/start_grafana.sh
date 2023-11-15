#!/bin/bash

# Create Docker volume named 'grafana-storage'
docker volume create grafana-storage

# Run Grafana Enterprise container
docker run -d -p 443:3000 --name=defendy-grafana \
  --volume grafana-storage:/var/lib/grafana \
  grafana/grafana-enterprise
