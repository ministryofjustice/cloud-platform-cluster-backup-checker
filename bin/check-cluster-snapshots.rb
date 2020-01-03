#!/usr/bin/env ruby

require "bundler/setup"
require "aws-sdk-iam"
require "aws-sdk-ec2"
require "date"
require "slack-notifier"

DAY_IN_SECONDS = 86400
ONE_DAY_OLD = 1
SLACK_CHANNEL = "#lower-priority-alarms"
SLACK_USERNAME = "MOJ Cloud Platform"

#####################################################
# This script uses IAM role with permissions and uses
# AssumeRole to create credentials dynamically in 'role_credentials'
######################################################
def main
  check_prerequisites

  role_arn = "arn:aws:iam::" + env("ACCOUNT_ID") + ":role/" + env("ROLE_NAME")

  puts "#{Time.new} Will sleep for #{n} seconds"
  sleep(rand(20))
  puts "#{Time.new} Waking now..."
  
  role_credentials = Aws::AssumeRoleCredentials.new(
    role_arn: role_arn,
    role_session_name: "cluster_backup_checker_session"
  )

  client = Aws::EC2::Client.new(
    region: env("AWS_REGION"),
    credentials: role_credentials
  )

  opts = {
    filters: [
      {name: "status", values: ["completed"]},
      {name: "tag:KubernetesCluster", values: [env("KUBERNETES_CLUSTER")]},
    ],
  }

  snapshots = get_snapshots(client, opts)

  # sort the snapshots returned by 'start_time' and
  # fetch the most_recent snapshot
  most_recent = snapshots.max_by { |snapshot| snapshot.start_time }

  age = Time.now.to_i - most_recent.start_time.to_i

  days_old = age / DAY_IN_SECONDS

  # compare the time to check if the snapshot is one day old

  if days_old > ONE_DAY_OLD
    send_message("Cluster snapshots failure", "Cluster snapshots are not recent")
  else
    puts "Cluster snapshots are recent. Time checked: " + Time.now.to_s
  end
end

def check_prerequisites
  %w[
    ACCOUNT_ID
    ROLE_NAME
    AWS_REGION
    KUBERNETES_CLUSTER
    SLACK_WEBHOOK
  ].each do |var|
    env(var)
  end
end

def env(var)
  ENV.fetch(var)
end

#####################################################
# get_snapshots() uses AWS API describe_snapshots to get
# the list of snapshots with the filters given in 'opts'.
# 'result' is looped until the next_token string is null.
######################################################
def get_snapshots(client, opts)
  snapshots = []
  next_token = "dummy"

  until next_token.nil?
    puts "Calling the AWS API..."
    result = client.describe_snapshots(opts)
    snapshots += result.snapshots
    next_token = result.next_token
    opts[:next_token] = next_token
  end

  snapshots
end

#####################################################
# send_message() calls the slack-notifier wrapper
# https://github.com/stevenosloan/slack-notifier to send
# notifications to respective slack channel for
# the given title and text
######################################################
def send_message(title, text)
  notifier = Slack::Notifier.new env("SLACK_WEBHOOK") do
    defaults channel: SLACK_CHANNEL,
             username: SLACK_USERNAME
  end

  message = {
    "attachments": [
      {
        "color": "#ff0000",
        "title": title.to_s,
        "title_link": "https://login.cloud-platform.service.justice.gov.uk",
        "text": text.to_s,
        "fields": [
          {
            "title": "Priority",
            "value": "High",
            "short": false,
          },
        ],
        "footer": "AWS MOJ Cloud Platform ",
        "ts": Time.now.to_i,
      },
    ],
  }
  notifier.ping message
end

main
