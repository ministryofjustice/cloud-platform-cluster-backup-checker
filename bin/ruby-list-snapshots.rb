#!/usr/bin/env ruby

require "bundler/setup"
require "aws-sdk-core"
require "aws-sdk-iam"
require "aws-sdk-ec2"
require "date"
require "slack-notifier"

DAY_IN_SECONDS = 86400

def get_snapshots(client, opts)
  snapshots = []
  next_token = "dummy"

  while !next_token.nil?
    puts "Calling the AWS API..."
    result = client.describe_snapshots(opts)
    snapshots += result.snapshots
    next_token = result.next_token
    opts[:next_token] = next_token
  end

  snapshots
end



def send_message(title, text)
  notifier = Slack::Notifier.new ENV.fetch('SLACK_WEBHOOK') do
      defaults channel: "#lower-priority-alarms",
               username: "MOJ Cloud Platform"
    end
    
  message = {
      "attachments": [
          {
              "fallback": "Required plain-text summary of the attachment.",
              "color": "#ff0000",
              "title": "#{title}",
              "title_link": "https://aws-login.apps.cloud-platform-live-0.k8s.integration.dsd.io/",
              "text": "#{text}",
              "fields": [
                  {
                      "title": "Priority",
                      "value": "High",
                      "short": false
                  }
              ],
            "footer": "AWS MOJ Cloud Platform ",
              "ts": Time.now.to_i
          }
      ]
  }
  notifier.ping message
end


#####################################################

role_arn = "arn:aws:iam::"+ENV.fetch('ACCOUNT_ID')+":role/"+ENV.fetch('ROLE_NAME')       
role_session_name = "cluster_backup_checker_session"
puts role_arn

role_credentials = Aws::AssumeRoleCredentials.new(
  role_arn: role_arn,
  role_session_name: role_session_name
)

puts role_credentials

client = Aws::EC2::Client.new(
  region: ENV.fetch('AWS_REGION'),
  credentials: role_credentials
)

opts = {
  filters: [
    { name: "status", values: [ "completed" ] },
    { name: "tag:KubernetesCluster", values: [ENV.fetch('KUBERNETES_CLUSTER')] },
  ]
}

snapshots = get_snapshots(client, opts)

most_recent = snapshots.sort_by { |snapshot| snapshot.start_time }.last

age = Time.now.to_i - most_recent.start_time.to_i

days_old = age / DAY_IN_SECONDS

current_time = Time.now
if days_old > 1
  send_message("Cluster backup failure", "Cluster snapshots backups not recent")
else
  puts "Cluster backup snapshots are recent. Time checked: "+current_time.inspect
end
