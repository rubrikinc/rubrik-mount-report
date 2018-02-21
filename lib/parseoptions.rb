require 'optparse'
require 'optparse/time'
require 'ostruct'
class ParseOptions

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  def self.parse(args)
  options = OpenStruct.new

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: %prog [options]"
    opts.separator ""
    opts.separator "Specific options:"
    opts.on('-l', '--login', "Perform no operations but test Rubrik Connectivity") do |login|
      options[:login] = login;
    end
    opts.separator ""
    opts.separator "Report options:"
    opts.on('-f','--from [string]', "Start Date (MM-DD-YYYY)") do |g|
      options[:from_date] = g;
    end
    opts.on('-t','--to [string]', "End Date (MM-DD-YYYY)") do |g|
      options[:to_date] = g;
    end
    opts.separator ""
    opts.separator "Common options:"
    opts.on('-n', '--node [Address]', "Rubrik Cluster Address/FQDN") do |node|
      options[:n] = node;
    end
    opts.on('-u', '--username [username]',"Rubrik Cluster Username") do |user|
      options[:u] = user;
    end
    opts.on('-p', '--password [password]', "Rubrik Cluster Password") do |pass|
      options[:p] = pass;
    end
    opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
    end
  end
  opt_parser.parse!(args)
   options
  end
end
