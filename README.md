# Cluster backup checker

Ruby script that checks the cluster backups are recent and send slack notifications if it could not find a recent backup.

All clusters managed by Cloud Platform has a snapshot lifecycle policy to take backup snapshots of all master nodes(etcd) volumes.

This project runs as a kubernetes cronjob and will require specific IAM role and permissions. It cannot be run locally.

## Installation

You need to have docker and awscli installed on your computer.

* Docker
```brew install docker```

You need to have AWS CLI installed 

* AWS CLI
```brew install awscli```

## Usage
A repository has been created on the AWS account *'cloud-platform-aws'* called *'754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker'*. You can build, tag and push to your own ECR repository and refer it in the Cronjob

1) Login to Amazon ECR.
```$(aws ecr get-login --no-include-email --region eu-west-2)```
You should have AWS credentials(access_key_id and secret_access_key) to login to ECR.

2) Build your Docker image using the following command.

```docker build -t cloud-platform/cluster-backup-checker .```

3) After the build completes, tag your image so you can push the image to the AWS ECR repository:

```docker tag cloud-platform/cluster-backup-checker:latest 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker:latest```

4) Run the following command to push this image to the AWS ECR repository:

```docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker:latest```

## Cluster environment and deployment
This project requires an IAM role with the following permissions *'ec2:DescribeSnapshots'* to apply on all EBS snapshots.

This script runs as a Kubernetes CronJob in the monitoring namespace on live-1 cluster. For more information on the depolyment, refer https://github.com/ministryofjustice/cloud-platform-infrastructure/blob/master/terraform/cloud-platform-components/cluster-backup-checker.tf

This script require the following environment variables and are provided using terraform variables.
```
ACCOUNT_ID <Account ID of your AWS account>
ROLE_NAME <Name of the IAM role created with correct permissions>
AWS_REGION <eu-west-2>
KUBERNETES_CLUSTER <cluster name>
SLACK_WEBHOOK <The webhook to send slack notifications>
```

## Development

If you want to develop the code, you will also need to install ruby 2.6.2, and run `bundle install` to install gems.




