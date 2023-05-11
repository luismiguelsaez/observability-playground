
## Cluster

```bash
kind create cluster --config kind-cluster.yaml
```

## Helm repositories

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

## Deploy

```bash
helm upgrade --install thanos oci://registry-1.docker.io/bitnamicharts/thanos --create-namespace -n monitoring --values values/thanos.yaml
helm upgrade --install prometheus prometheus-community/prometheus --version 22.4.1 --create-namespace -n monitoring --values values/prometheus.yaml
helm upgrade --install grafana grafana/grafana -n monitoring --version 6.56.2 --create-namespace -n monitoring --values values/grafana.yaml
```

## Connect

```bash
k port-forward svc/grafana 8080:80 -n monitoring
```
