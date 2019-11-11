#!/usr/bin/env ruby

require 'bundler/setup'
require "aws-sdk-iam"
require "aws-sdk-ec2"
require "date"
require 'ansi'
require 'elasticsearch'
require 'elasticsearch/transport'
require 'faraday_middleware'
require 'faraday_middleware/aws_sigv4'



def main
  # check_prerequisites
  ENV['AWS_REGION'] = "eu-west-2"
  role_arn = "arn:aws:iam::754256621582:role/cloud-platform-f9dc126baed8e66b"

  role_credentials = Aws::AssumeRoleCredentials.new(
    role_arn: role_arn,
    role_session_name: "es-session"
  )
  
  # Aws.config.update(credentials: role_credentials)

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

    # Licensed to Elasticsearch B.V under one or more agreements.
  # Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
  # See the LICENSE file in the project root for more information

  # An example of using the percolator with Elasticsearch 5.x and higher
  # ====================================================================
  #
  # See:
  #
  # * https://www.elastic.co/blog/elasticsearch-percolator-continues-to-evolve
  # * https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-percolate-query.html


  # client = Elasticsearch::Client.new log: true

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

  client = Elasticsearch::Client.new(url: host, log:true) do |f|
    f.request :aws_sigv4,
      service: service,
      region: region,
      access_key_id: role_credentials.credentials.access_key_id,
      secret_access_key: role_credentials.credentials.secret_access_key,
      session_token: role_credentials.credentials.session_token
  end

  puts client.index index: index, type: type, id: id, body: document

  puts client.search index: 'my-alerts', body: {
      query: {
        percolate: {
          field: 'query',
          document: {
            title: "Second"
          }
        }
      }
    }

 

  # Delete the indices used for the example
  #
  # client.indices.delete index: ['my-alerts','my-messages'], ignore: 404

  # Set up the mapping for the index
  #
  # * Register the "percolate" type for the `query` field
  # * Set up the mapping for the `message` field
  #
  # client.indices.create index: 'my-alerts',
  #   body: {
  #     mappings: {
  #       properties: {
  #         query: {
  #           type: 'percolator'
  #         },
  #         message: {
  #           type: 'text'
  #         }
  #       }
  #     }
  #   }

  # Store alert for messages containing "foo"
  #
  # client.index index: 'my-alerts',
  #             type: 'doc',
  #             id: 'alert-1',
  #             body: { query: { match: { message: 'foo' } } }


  # Store alert for messages containing "bar"
  #
  # client.index index: 'my-alerts',
  #             type: 'doc',
  #             id: 'alert-2',
  #             body: { query: { match: { message: 'bar' } } }

  # # Store alert for messages containing "baz"
  # #
  # client.index index: 'my-alerts',
  #             type: 'doc',
  #             id: 'alert-3',
  #             body: { query: { match: { message: 'baz' } } }

  # client.indices.refresh index: 'my-alerts'

  # Percolate a piece of text against the queries
  #
  # results = client.search index: 'my-alerts', body: {
  #   query: {
  #     percolate: {
  #       field: 'query',
  #       document: {
  #         message: "Foo Bar"
  #       }
  #     }
  #   }
  # }
 
  # puts client.cluster.health

  # puts client.search q: 'bar'

  # puts "Which alerts match the text 'Foo Bar'?".ansi(:bold),
      # '> ' + results['hits']['hits'].map { |r| r['_id'] }.join(', ')

  # client.index index: 'my-messages', type: 'doc', id: 123, body: { message: "Foo Bar Baz" }

  # client.indices.refresh index: 'my-messages'

  # results = client.search index: 'my-alerts', body: {
  #   query: {
  #     percolate: {
  #       field: 'query',
  #       index: 'my-messages',
  #       type: 'doc',
  #       id: 123
  #     }
  #   }
  # }

  # puts "Which alerts match the document [my-messages/doc/123]?".ansi(:bold),
  #     '> ' + results['hits']['hits'].map { |r| r['_id'] }.join(', ')

end

main

