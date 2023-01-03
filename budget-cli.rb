require 'optparse'

Options = Struct.new(:name)

class Parser
  def self.parse
    args = Options.new("world")

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: budget-cli.rb [options]"

      opts.on("-nNAME", "--name=NAME", "Name to say hello to") do |n|
        args.name = n
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

p ARGV
options = Parser.parse
p options
