require 'optparse'
require_relative 'Arguments'

class Parser
  def self.parse
    args = Arguments.new()

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: budget-cli.rb [options]"

      opts.on("-o {hash}", "--output {hash}",
              "Insert transaction into table, {name, date, desc, amount, category}") do |output|
        p output
        args.set_output output
      end

      #opts.on("-b", "--breakdown",
      #        "[begin-date end-date] show breakdown of spending") do
      #  args.breakdown = true
      #end

      #opts.on("-r", "--recent",
      #        "[limit] show recent transactions") do
      #  args.recent = true
      #end

      #opts.on("-h", "--help", "Prints this help") do
      #  puts opts
      #  exit
      #end
    end

    opt_parser.parse!
    return args
  end
end

