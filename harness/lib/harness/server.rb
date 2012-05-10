require "json"
require "sinatra/base"
require "thin"

require "harness/datastore"

module Harness
  class Server < Sinatra::Base
    def self.get_or_post(path, opts={}, &block)
      get(path, opts, &block)
      post(path, opts, &block)
    end

    get_or_post '/next_page/:seq_list' do
      response = {}
      params[:seq_list].split(",").map { |seq| seq.to_i }.each do |seq|
        response[seq] = Harness::datastore.get_page_seq seq
      end
      response.to_json
    end

    get_or_post '/next_rev/:seq_list' do
      response = {}
      params[:seq_list].split(",").map { |seq| seq.to_i }.each do |seq|
        response[seq] = Harness::datastore.get_rev_seq seq
        response[seq][:fulltext].force_encoding "UTF-8"
      end
      response.to_json
    end

    get_or_post "/num_revs" do
      { num_revs: Harness::datastore.get_num_revs }.to_json
    end


    get_or_post %r{/(index)?} do
      "This server is a test harness for sr.<br/>" +
        'See <a href="http://wiki.hyperbo.la/sr">wiki.hyperbo.la/sr</a> for more info.'
    end
  end
end

