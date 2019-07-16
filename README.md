# Cluster backup checker

Ruby code that checks the cluster backup ran regularly and successfully.

## Installation

You need to have docker installed on your computer.


## Usage



## Development

If you want to develop the code, you will also need to install ruby 2.6.2, and run `bundle install` to install gems.

## Background

The following is some detail on how the scripts work, and the resources they require.

### Environment variables

These scripts require the following environment variables to be set.

```
KUBERBETES_CLUSTER <cluster name>
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
SLACK_WEBHOOK <The webhook to send slack notifications>
```