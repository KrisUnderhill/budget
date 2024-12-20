require 'optparse'
require_relative 'Arguments'

class Parser
  def self.parse
    args = Arguments.new()

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: budget-cli.rb [options]"

      opts.on("-t {hash}", "--transaction {hash}",
              "Insert transaction into table, {name, date, desc, amount, category}") do |output|
        args.set_transaction(parse_args_from_h(output))
      end

      opts.on("--update_transaction {hash}",
              "updates a transaction by id, {id, name, date, desc, amount, category") do |up_trans|
        args.set_up_trans(parse_args_from_h(up_trans))
      end

      opts.on("--remove_transaction id",
              "removes a transaction by id") do |id|
        args.set_rm_trans(id)
      end

      opts.on("-i", "--input {hash}",
              "Input funds into categories, {name, date, (multiple)category=>amount}") do |input|
        args.set_input(parse_args_from_h(input))
      end

      opts.on("--remove_input id",
              "remove an input by id") do |id|
        args.set_rm_input(id)
      end

      opts.on("--update_input {hash}",
              "Update Input funds, {id, name, date, (multiple)category=>amount}") do |input|
        args.set_up_input(parse_args_from_h(input))
      end

      opts.on("--add_account {hash}",
              "Adds an account (hash) {name, type, balance, target}") do |add_account|
        args.set_add_account(parse_args_from_h(add_account))
      end

      opts.on("--update_account {hash}",
              "updates an account by name (hash) {name, new_name, type, balance, target}") do |up_account|
        args.set_up_account(parse_args_from_h(up_account))
      end

      opts.on("--remove_account name",
              "removes an account by name") do |name|
        args.set_rm_account(name)
      end

      opts.on("-b", "--breakdown {hash}",
              "show breakdown of spending, {type (one of: {month custom 6m year ytd}, date_range(optional)}") do |breakdown|
        args.set_breakdown(parse_args_from_h(breakdown))
      end

      opts.on("-r", "--recent {hash}",
              "show recent transactions, {type: limit [num], month, date [range_start, range_end]}") do |recent|
        args.set_recent(parse_args_from_h(recent))
      end

      opts.on("--list-accounts", "list account data") do
        args.set_list_accounts
      end

      opts.on("--recent_inputs {hash}",
              "show recent transactions, {type: limit [num], month, date [range_start, range_end]}") do |recent_inputs|
        args.set_recent_inputs(parse_args_from_h(recent_inputs))
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

