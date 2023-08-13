require 'optparse'

Options = Struct.new(:insert, :breakdown, :recent)

class Parser
  def self.parse
    args = Options.new()

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: budget-cli.rb [options]"

      opts.on("-i", "--insert",
              "[NAME DESCRIPTION DATE AMOUNT CATEGORY]\n Insert transaction into table") do |insert|
        args.insert = true
      end

      opts.on("-b", "--breakdown",
              "[begin-date end-date] show breakdown of spending") do
        args.breakdown = true
      end

      opts.on("-r", "--recent",
              "[limit] show recent transactions") do
        args.recent = true
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!
    return args
  end
end

