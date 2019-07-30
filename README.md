# Cluster backup checker

All kubernetes clusters managed by Cloud Platform have a data lifecycle policy. This policy takes a [snapshot of all etcd master node volumes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster) which are tagged with *'k8s.io/role/master:1'*.

This Ruby script checks that there has been a recent snapshot and will send a slack notification if there has not been one.

This project runs as a kubernetes cronjob and requires a specific IAM role and permissions. It cannot be run locally.

## Installation

You need to have docker and awscli installed on your computer.

* Docker
```brew install docker```

You need to have AWS CLI installed 

* AWS CLI
```brew install awscli```

## Usage
A repository has been created on the AWS account *'cloud-platform-aws'* called *'754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker'*. 

You can build, tag and push to your own ECR repository and use it to run as a cronjob or as a pod in your own namespace. 

1) Login to Amazon ECR. 

```
$(aws ecr get-login --no-include-email --region eu-west-2)
```

You should have AWS credentials(access_key_id and secret_access_key) to login to ECR.

2) Build your Docker image using the following command.

```
docker build -t cloud-platform/cluster-backup-checker .
```

3) After the build completes, tag your image so you can push the image to the AWS ECR repository:

```
docker tag cloud-platform/cluster-backup-checker:latest 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker:<VERSION>
```

4) Run the following command to push this image to the AWS ECR repository:

```
docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/cluster-backup-checker:<VERSION>
```

## Cluster environment and deployment
This project requires an IAM role with the following permissions *'ec2:DescribeSnapshots'*.

This script runs as a Kubernetes CronJob in the monitoring namespace on live-1 cluster. For more information on the deployment, refer [cloud-platform-infrastructure/terraform/cloud-platform-components/cluster-backup-checker.tf](https://github.com/ministryofjustice/cloud-platform-infrastructure/blob/master/terraform/cloud-platform-components/cluster-backup-checker.tf)

The following environment variables are set using terraform with *'[cloud-platform-infrastructure/terraform/cloud-platform-components](https://github.com/ministryofjustice/cloud-platform-infrastructure/tree/master/terraform/cloud-platform-components)'* and these are passed to the script when applying terraform. Therefore you do not need to setup these.

```
ACCOUNT_ID <Account ID of your AWS account>
ROLE_NAME <Name of the IAM role created with correct permissions>
AWS_REGION <eu-west-2>
KUBERNETES_CLUSTER <cluster name>
SLACK_WEBHOOK <The webhook to send slack notifications>
```

## Development

If you want to develop the code, you will also need to install ruby 2.6.2, and run `bundle install` to install gems.




