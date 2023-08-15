require 'optparse'
require_relative 'Arguments'

class Parser
  def self.parse
    args = Arguments.new()

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: budget-cli.rb [options]"

      opts.on("-o {hash}", "--output {hash}",
              "Insert transaction into table, {name, date, desc, amount, category}") do |output|
        args.set_output(parse_args_from_h(output))
      end

      opts.on("-b", "--breakdown {hash}",
              "show breakdown of spending, {type (one of: {month custom 6m year ytd}, date_range(optional)}") do |inputs|
        args.set_breakdown(parse_args_from_h(inputs))
      end

      opts.on("-r", "--recent {hash}",
              "show recent transactions, {type: limit [num], month, date [range_start, range_end]}") do |recents|
        args.set_recent(parse_args_from_h(recents))
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!
    return args
  end

  private
  def self.parse_args_from_h( string_h )
    hash_args = {}
    #zero or more spaces at beginning
    #key 
    #zero or more space then => followed by zero or more space
    #(or) no space then : followed by one or more space
    #value (can use spaces if surrounded by single quote (')
    #ending with 0 or 1 comma
    while /\s*(?<key>(\w+))(\s*=>|:\s+)\s*(?<value>([\w.-]+|'[\w\s.-]*')),?/ =~ string_h
      hash_args[key.to_sym] = value.delete("'")
      string_h = $' # string after match
    end
    hash_args
  end
end

