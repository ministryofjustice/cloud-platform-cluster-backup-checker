#!/usr/bin/env ruby

require 'bundler/setup'
require "aws-sdk-iam"
require "aws-sdk-ec2"
require "date"
require 'elasticsearch'
require 'elasticsearch/transport'
require 'faraday_middleware'
require 'faraday_middleware/aws_sigv4'



def main
  # check_prerequisites
  ENV['AWS_REGION'] = "eu-west-2"
  role_arn = "arn:aws:iam::754256621582:role/cloud-platform-aba9c4f9c36226ad"

  role_credentials = Aws::AssumeRoleCredentials.new(
    role_arn: role_arn,
    role_session_name: "es-session"
  )
  
  Aws.config.update(credentials: role_credentials)

  puts role_credentials.credentials.access_key_id

  # creds = Aws::EC2::Client.new(
  #   region: "eu-west-2",
  #   credentials: role_credentials
  # )

  # opts = {
  #   filters: [
  #     {name: "status", values: ["completed"]},
  #     {name: "tag:KubernetesCluster", values: ["es-test-pk.cloud-platform.service.justice.gov.uk"]},
  #   ],
  # }

  host = 'https://vpc-cloud-platform-example-es-6myhvvkxaxzd4nyxpwvw2eyyyu.eu-west-2.es.amazonaws.com' # e.g. https://my-domain.region.es.amazonaws.com
  index = 'ruby-index'
  type = '_doc'
  id = '1'
  document = {
  year: 2007,
  title: '5 Centimeters per Second',
  info: {
    plot: 'Told in three interconnected segments, we follow a young man named Takaki through his life.',
    rating: 7.7
  }
  }

  region = 'eu-west-2' # e.g. us-west-1
  service = 'es'

  client = Faraday.new(url: host) do |f|
    f.request :aws_sigv4,
      access_key_id: role_credentials.credentials.access_key_id,
      secret_access_key: role_credentials.credentials.secret_access_key,
      session_token: role_credentials.credentials.session_token,
      service: 'es',
      region: region

    f.adapter Faraday.default_adapter
  end

  res = client.get '/index'

  puts res.body
end


main

