
# Dependencies

```bash
brew install jsonnet-bundler
```

# Test

```bash
git clone https://github.com/grafana/grafonnet-lib.git
docker run -v $PWD:/src bitnami/jsonnet:0.20.0 -J . /src/k8s-general.jsonnet
```
