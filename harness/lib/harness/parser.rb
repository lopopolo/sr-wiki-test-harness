require "base64"
require "nokogiri"
require "yaml"
require "zlib"

module Harness
  # this class parses the fields we care about out of the wiki dump
  # and saves the munged data to disk as a yaml doc.
  class Parser
    attr_accessor :pages, :revisions # both keyed by page id
    attr_accessor :verbose
    attr_accessor :page_counter, :revision_counter
    def initialize dump, verbose = false
      @xml_files = dump.to_a # filenames of xml dumps
      @verbose = verbose
      @pages = Hash.new
      @revisions = Hash.new
      @page_counter = @revision_counter = 0
    end

    # munge data into yaml containing only the keys we want
    # pages
    #   seq
    #     id
    #     title
    #     num_revisions
    # revisions
    #   seq
    #     page_id
    #     rev_id
    #     fulltext
    #     length
    def parse_all
      @xml_files.each do |dump|
        parse dump
        # dump to a file so we don't need to parse again
        File.open("#{dump}.yaml", "w") do |yaml_dump|
          YAML::dump({ pages: @pages, revisions: @revisions }, yaml_dump)
        end
        # reset hashes
        @pages.clear
        @revisions.clear
        @page_counter = @revision_counter = 0
      end
    end

    def parse dump
      File.open dump do |f|
        in_page = false
        current_page = ""
        while line = f.gets
          # short circuit
          next if !in_page && !(line =~ /page/)
          if line =~ /<page>/
            in_page = true
          elsif line =~ /<\/page>/
            in_page = false
            current_page += line
            parse_page current_page, @page_counter
            current_page = ""
            @page_counter += 1
          end
          current_page += line if in_page
        end
      end
    end

    def parse_page xml, page_count
      page = Nokogiri::XML xml
      title = page.at_xpath("//title").content
      id = page.at_xpath("//id").content.to_i
      @pages[page_count] = { id: id, title: title, num_revisions: 0 }
      revs = page.xpath("//revision")
      revs.each do |rev|
        current_rev = @revision_counter
        Thread.new do
          revision_id = rev.at_xpath("//id").content.to_i
          fulltext = rev.at_xpath("//text").content
          # encode the fulltext to save space
          fulltext = Base64::encode64(fulltext)
          # deflate to save more space
          fulltext = Zlib::Deflate.deflate(fulltext)
          @revisions[current_rev] = { page_id: id, rev_id: revision_id,
                                          fulltext: fulltext, length: rev.at_xpath("//text")["bytes"].to_i }
        end
        @revision_counter += 1
        @pages[page_count][:num_revisions] += 1
      end
      puts @pages[page_count].inspect if @verbose
    end
  end
end

