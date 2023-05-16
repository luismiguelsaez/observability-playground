
## Cluster

```bash
kind create cluster --config kind-cluster.yaml
```

## Helm repositories

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

## Deploy

- Create bucket

```bash
export AWS_PROFILE=<profile_name>
export AWS_BUCKET=thanos-test-20230513
aws s3api create-bucket --bucket $AWS_BUCKET --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
```

- Create user and assign permissions

```bash
aws iam create-user --user-name thanos-test
USER_ARN=$(aws iam get-user --user-name thanos-test | jq -r '.User.Arn')

cat << EOF > /tmp/bucket-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Principal": {
          "AWS": [
              "$USER_ARN"
          ]
      },
      "Effect": "Allow",
      "Action": [
          "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::$AWS_BUCKET",
        "arn:aws:s3:::$AWS_BUCKET/*"
      ]
    }
	]
}
EOF

aws s3api put-bucket-policy --bucket $AWS_BUCKET --policy file:///tmp/bucket-policy.json 

aws iam create-access-key --user-name thanos-test
```

- Create object store `Secret`

```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: bucket-s3
  namespace: monitoring
stringData:
  objstore.yml: |
    type: S3
    prefix: standard-ia
    config:
      endpoint: s3.eu-central-1.amazonaws.com
      region: eu-central-1
      bucket: $AWS_BUCKET
      aws_sdk_auth: false
      access_key: 
      secret_key: 
      put_user_metadata:
        X-Amz-Storage-Class: STANDARD_IA
      trace:
        enable: true
EOF
```

- Deploy components
  ```bash
  helm upgrade --install prometheus prometheus-community/prometheus --version 22.4.1 --create-namespace -n monitoring --values values/prometheus.yaml
  helm upgrade --install thanos bitnami/thanos --version 12.5.2 --create-namespace -n monitoring --values values/thanos.yaml
  helm upgrade --install grafana grafana/grafana -n monitoring --version 6.56.2 --create-namespace -n monitoring --values values/grafana.yaml
  ```

## Connect

```bash
k port-forward svc/grafana 8080:80 -n monitoring
```
