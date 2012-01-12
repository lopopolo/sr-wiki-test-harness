require "yaml"

module Harness
  def self.datastore= ds
    @datastore = ds
  end

  def self.datastore
    @datastore
  end

  class Datastore
    def initialize yaml_file
      @yaml_file = yaml_file
      @data = YAML::load(File.open(yaml_file))
    end

    def get_page_seq seq
      @data[:pages][seq]
    end

    def get_rev_seq seq
      @data[:revisions][seq]
    end
  end
end

