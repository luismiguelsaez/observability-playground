
# Dependencies

```bash
brew install jsonnet-bundler
```

# Docs

- https://grafana.github.io/grafonnet-lib

# Test

```bash
git clone https://github.com/grafana/grafonnet-lib.git
payload=$(docker run -v $PWD:/src bitnami/jsonnet:0.20.0 -J . /src/jmx-exporter.jsonnet)

curl -XPOST --user "admin:prom-operator" -H"Content-type:application/json" ${GRAFANA_URL}/api/dashboards/db -d '
{
  "dashboard": '$payload',
  "overwrite": true
}'
```



-> docker run -v $PWD/metrics/grafana/dashboards:/src --entrypoint=sh -it --rm -w /src grafana/jsonnet-build:4fd8fef
```bash
jb install
jsonnet -J ./vendor jmx-exporter.jsonnet
```
