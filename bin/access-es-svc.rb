#!/usr/bin/env ruby

require 'bundler/setup'
require "aws-sdk-iam"
require "aws-sdk-ec2"
require "date"
require 'aws-sdk-elasticsearchservice'
require "net/http"
require "uri"

def main

  host = 'http://aws-es-proxy-service:9200' # e.g. https://my-domain.region.es.amazonaws.com
  index = 'ruby-index'
  type = '_doc'
  id = '2'
  document = {
  year: 2008,
  title: 'A test title for elasticsearch',
  info: {
    plot: 'This is a description to test elasticsearch with ruby code. This should add an index ruby-index and should be able to search with any string mentioned here',
    rating: 7.7
  }
  }


  uri = URI(host + '/' + index + '/' + type + '/' + id)
  
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Put.new uri
    request.body = document.to_json
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
        "query": "elasticsearch"
      }
    }
  }


  uri = URI(host + '/' + index + '/_search')
  
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Post.new uri
    request.body = document.to_json
    request['Content-Type'] = 'application/json'
    response = http.request request
    puts response.code + response.body
  end

  
end


main

