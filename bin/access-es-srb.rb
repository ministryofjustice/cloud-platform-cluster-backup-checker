#!/usr/bin/env ruby

require 'bundler/setup'
require "aws-sdk-iam"
require "aws-sdk-ec2"
require "date"
require 'aws-sdk-elasticsearchservice'
require "net/http"
require "uri"



def main
  # check_prerequisites
  ENV['AWS_REGION'] = "eu-west-2"
  role_arn = "arn:aws:iam::754256621582:role/cloud-platform-e57bab8894498ca3"

  role_credentials = Aws::AssumeRoleCredentials.new(
    role_arn: role_arn,
    role_session_name: "es-session"
  )
  

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
  id = '2'
  document = {
  year: 2008,
  title: '5 Centimeters per Second',
  info: {
    plot: 'Told in three interconnected segments, we follow a young man named Takaki through his life.',
    rating: 7.7
  }
  }



  region = 'eu-west-2' # e.g. us-west-1
  service = 'es'

  signer = Aws::Sigv4::Signer.new(
    service: service,
    region: region,
    access_key_id: role_credentials.credentials.access_key_id,
    secret_access_key: role_credentials.credentials.secret_access_key,
    session_token: role_credentials.credentials.session_token
  )
  
  puts signer
  
  signature = signer.sign_request(
    http_method: 'PUT',
    url: host + '/' + index + '/' + type + '/' + id,
    body: document.to_json
  )
  
  uri = URI(host + '/' + index + '/' + type + '/' + id)
  
  Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
    request = Net::HTTP::Put.new uri
    request.body = document.to_json
    request['Host'] = signature.headers['host']
    request['X-Amz-Date'] = signature.headers['x-amz-date']
    request['X-Amz-Security-Token'] = signature.headers['x-amz-security-token']
    request['X-Amz-Content-Sha256']= signature.headers['x-amz-content-sha256']
    request['Authorization'] = signature.headers['authorization']
    request['Content-Type'] = 'application/json'
    response = http.request request
    puts response.code + response.body
  end


  document = {
    "size": 1,
    "sort": {
      "year": {
        "order": "desc"
      }
    },
    "query": {
      "query_string": {
        "query": "young"
      }
    }
  }


  signature = signer.sign_request(
    http_method: 'POST',
    url: host + '/' + index + '/_search',
    body: document.to_json
  )

  uri = URI(host + '/' + index + '/_search')
  
  Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
    request = Net::HTTP::Post.new uri
    request.body = document.to_json
    request['Host'] = signature.headers['host']
    request['X-Amz-Date'] = signature.headers['x-amz-date']
    request['X-Amz-Security-Token'] = signature.headers['x-amz-security-token']
    request['X-Amz-Content-Sha256']= signature.headers['x-amz-content-sha256']
    request['Authorization'] = signature.headers['authorization']
    request['Content-Type'] = 'application/json'
    response = http.request request
    puts response.code + response.body
  end

  
end


main

