#!/usr/bin/env ruby

# setup load path
$:.push File.join(File.dirname(__FILE__), "lib")

require "harness/datastore"
require "harness/parser"
require "harness/server"
require "harness/version"

if __FILE__ == $0
  require "trollop"
  opts = Trollop::options do
    opt :port, "Port to run sinatra on", default: 7777
    opt :dataset, "/path/to/dataset.yaml or /path/to/wikidump.xml", type: String
    opt :generate_yaml, "Generate the yaml files from the wiki xml dumps"
  end

  Trollop::die :dataset, "Must be given" if !opts[:dataset]

  if opts[:generate_yaml]
    parser = Harness::Parser.new opts[:dataset]
    parser.parse_all
    opts[:dataset] = "#{opts[:dataset]}.yaml"
  end

  Harness::datastore = Harness::Datastore.new opts[:dataset]
  Harness::Server.run! port: opts[:port]
end

