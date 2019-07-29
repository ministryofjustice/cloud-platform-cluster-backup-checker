# Cluster backup checker

Ruby code that checks the cluster backup snapshots are recent and less that 24 hours old. This script will send slack notifications if it could not find a recent snapshot. Specify the cluster_name as a environment variable ```KUBERBETES_CLUSTER <cluster name>``` for which cluster you want to check the snapshot backup. 

## Installation

You need to have docker installed on your computer.

## Pushing to ECR
### Prerequisites
* Docker
```brew install docker```

* AWS CLI
```brew install awscli```

The decision was made to use the Amazon Elastic Container Registry. ECR is a fully-managed [Docker](https://aws.amazon.com/docker/) container registry that makes it easy for developers to store, manage, and deploy Docker container images.

A repository has been created on the AWS account *'cloud-platform-aws'* called *'arn:aws:ecr:eu-west-2:754256621582:repository/ƒ'*.

### Building, tagging and pushing to ECR
1) Retrieve the `docker login` command that you can use to authenticate your Docker client to your registry:

```aws ecr get-login --no-include-email --region eu-west-2```

2) Run the `docker login` command that was returned in the previous step.

3) Build your Docker image using the following command.

```docker build -t cloud-platform/cluster-backup-checker .```

4) After the build completes, tag your image so you can push the image to this repository:

```docker tag cloud-platform/cluster-backup-checker:latest 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker:latest```

5) Run the following command to push this image to your newly created AWS repository:

```docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker:latest```

### Environment variables

These scripts require the following environment variables to be set.

```
ACCOUNT_ID
ROLE_NAME
AWS_REGION
KUBERBETES_CLUSTER <cluster name>
SLACK_WEBHOOK <The webhook to send slack notifications>
```

### Cluster environment and deployment
The checker script requires an IAM role with the following permissions: ecr:DescribeSnapshots on all ECR repositories.

The checker script runs as a Kubernetes CronJob in the monitoring namespace on live-1 cluster. For more information on the depolyment, refer https://github.com/ministryofjustice/cloud-platform-infrastructure/blob/master/terraform/cloud-platform-components/cluster-backup-checker.tf

## Development

If you want to develop the code, you will also need to install ruby 2.6.2, and run `bundle install` to install gems.




