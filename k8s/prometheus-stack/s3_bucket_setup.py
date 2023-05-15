import boto3
from sys import argv

bucket_name = 'thanos-test-20230513'
user_name = 'thanos-test'

session = boto3.Session()
s3_client = session.client("s3",region_name="eu-central-1")
iam_client = session.client("iam")

buckets = s3_client.list_buckets()

if len([i['Name'] for i in buckets['Buckets'] if i['Name'] == bucket_name]) < 1:

  bucket = s3_client.create_bucket(
    Bucket="thanos-test-20230513",
    ACL="private",
    CreateBucketConfiguration={
      'LocationConstraint': 'eu-central-1'
    }
  )

else:

  print('Bucket already exists')

users = iam_client.list_users()

users_arns = [i['Arn'] for i in users['Users'] if i['UserName'] == user_name]
if len(users_arns) < 1:

  user = iam_client.create_user(UserName=user_name)
  user_arn = user['Arn']

else:

  print('User already exists')
  user_arn = users_arns[0]

s3_bucket_policy = '{"Version": "2012-10-17","Statement":[{"Sid":"Statement1","Principal":{"AWS":["' + user_arn + '"]},"Effect":"Allow","Action":["s3:*"],"Resource":["arn:aws:s3:::' + bucket_name + '","arn:aws:s3:::' + bucket_name + '/*"]}]}'

print(f'Adding policy: {s3_bucket_policy}')

s3_client.put_bucket_policy(
  Bucket='thanos-test-20230513',
  Policy=s3_bucket_policy
)

iam_user_key = iam_client.create_access_key(
    UserName=user_name
)

print(f"Created access key: { iam_user_key['AccessKey']['AccessKeyId'] } / { iam_user_key['AccessKey']['SecretAccessKey'] }")
