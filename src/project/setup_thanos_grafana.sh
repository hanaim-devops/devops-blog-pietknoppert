#!/bin/bash

# Maak de mappenstructuur aan
mkdir -p thanos
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards/dashboards

# Maak en vul het bestand 'prometheus.yml'
cat <<EOL > prometheus.yml
global:
  scrape_interval: 15s

  external_labels:
    monitor: 'test-monitor'
    cluster: 'test-cluster'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'test-api'
    static_configs:
      - targets: ['test-api:5000']
    metrics_path: /metrics
EOL

# Maak en vul het bestand 'objstore.yml'
cat <<EOL > thanos/objstore.yml
type: FILESYSTEM
config:
  directory: /data
EOL

# Maak en vul het bestand 'test-api-dashboard.json'
cat <<EOL > grafana/provisioning/dashboards/dashboards/test-api-dashboard.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "panels": [
    {
      "datasource": "Thanos",
      "fieldConfig": {
        "defaults": {
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 2,
      "options": {
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "targets": [
        {
          "expr": "sum by (status) (request_count_total)",
          "interval": "",
          "legendFormat": "{{status}}",
          "refId": "A"
        }
      ],
      "title": "Total aantal requests opbasis van status",
      "type": "bargauge"
    }
  ],
  "schemaVersion": 30,
  "title": "Test API Dashboard",
  "version": 1
}
EOL

# Maak en vul het bestand 'dashboard.yml'
cat <<EOL > grafana/provisioning/dashboards/dashboard.yml
apiVersion: 1
providers:
  - name: 'Test API Dashboards'
    orgId: 1
    folder: ''
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards/dashboards
EOL

# Maak en vul het bestand 'datasource.yml'
cat <<EOL > grafana/provisioning/datasources/datasource.yml
apiVersion: 1
datasources:
  - name: Thanos
    type: prometheus
    access: proxy
    url: http://thanos-query:9090
    isDefault: true
EOL

# Maak en vul het bestand 'docker-compose.yml'
cat <<EOL > docker-compose.yml
services:
  prometheus:
    image: prom/prometheus:v2.41.0
    container_name: prometheus
    volumes:
      - prometheus-data:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --web.enable-lifecycle
      - --storage.tsdb.min-block-duration=2h
      - --storage.tsdb.max-block-duration=2h
    ports:
      - "9090:9090"
    networks:
      - monitoring
    depends_on:
      - test-api

  thanos-sidecar:
    image: quay.io/thanos/thanos:v0.32.2
    container_name: thanos-sidecar
    user: "0"
    command:
      - sidecar
      - --prometheus.url=http://prometheus:9090
      - --grpc-address=0.0.0.0:10901
      - --http-address=0.0.0.0:10902
      - --tsdb.path=/prometheus
      - --objstore.config-file=/etc/thanos/objstore.yml
    volumes:
      - prometheus-data:/prometheus
      - ./thanos/objstore.yml:/etc/thanos/objstore.yml
    networks:
      - monitoring
    depends_on:
      - prometheus

  thanos-store:
    image: quay.io/thanos/thanos:v0.32.2
    container_name: thanos-store
    user: "0"
    command:
      - store
      - --grpc-address=0.0.0.0:10901
      - --http-address=0.0.0.0:10902
      - --data-dir=/data
      - --objstore.config-file=/etc/thanos/objstore.yml
    volumes:
      - thanos-data:/data
      - ./thanos/objstore.yml:/etc/thanos/objstore.yml
    networks:
      - monitoring

  thanos-query:
    image: quay.io/thanos/thanos:v0.32.2
    container_name: thanos-query
    command:
      - query
      - --http-address=0.0.0.0:9090
      - --store=thanos-sidecar:10901
      - --store=thanos-store:10901
    ports:
      - "19090:9090"
    networks:
      - monitoring
    depends_on:
      - thanos-sidecar
      - thanos-store

  grafana:
    image: grafana/grafana:9.5.3
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
      - ./grafana/provisioning/:/etc/grafana/provisioning/
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - monitoring
    depends_on:
      - thanos-query

  test-api:
    image: jelmer0314/test-api:latest
    container_name: test-api
    ports:
      - "5000:5000"
    networks:
      - monitoring

volumes:
  prometheus-data:
    driver: local
  thanos-data:
    driver: local
  grafana-storage:
    driver: local

networks:
  monitoring:
    driver: bridge
EOL

echo "Mappenstructuur, bestanden en docker-compose.yml succesvol aangemaakt."