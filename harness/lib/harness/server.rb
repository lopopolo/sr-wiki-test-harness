require "json"
require "sinatra/base"
require "thin"

require "harness/datastore"

module Harness
  class Server < Sinatra::Base
    get '/next_page/:seq_list' do
      response = {}
      params[:seq_list].split(",").map { |seq| seq.to_i }.each do |seq|
        response[seq] = Harness::datastore.get_page_seq seq
      end
      puts response.inspect
      response.to_json
    end

    get '/next_rev/:seq_list' do
      response = {}
      params[:seq_list].split(",").map { |seq| seq.to_i }.each do |seq|
        response[seq] = Harness::datastore.get_rev_seq seq
        response[seq][:fulltext].force_encoding "UTF-8"
      end
      response.to_json
    end

    get %r{/(index)?} do
      "This server is a test harness for sr.<br/>" +
        'See <a href="http://wiki.hyperbo.la/sr">wiki.hyperbo.la/sr</a> for more info.'
    end
  end
end

