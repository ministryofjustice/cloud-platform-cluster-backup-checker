#!/usr/bin/env ruby

require 'bundler/setup'
require "date"
require "net/http"
require "uri"
require "sqlite3"
require "sqlite3-ruby"
require "random_word_generator"

def main

  host = 'http://aws-es-proxy-service:9200' # e.g. https://my-domain.region.es.amazonaws.com
  index = 'ruby-index'
  type = '_doc'
  id = rand(4)
  document = {
  year: 2008,
  title: 'Profiles',
  info: {
    profile: RandomWordGenerator.composed(14, 500)
    rating: 5.0
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
        "query": "young"
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

