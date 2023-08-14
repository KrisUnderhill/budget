require_relative 'Money'
require_relative 'Data'

class Arguments
  attr_accessor :operation, :args
  Operations = %w[output input breakdown list]
  OutputArgs = %w[name date desc amount category]

  def initialize
    @operation = nil 
    @args = {}
  end

  def set_output args_string
    @operation = "output"
    temp_args = parse_args_from_h args_string
    p temp_args
    @args = validateOutputArgs temp_args
    nil
  end

  private 
  def parse_args_from_h( string_h )
    hash_args = {}
    #zero or more spaces at beginning
    #key 
    #zero or more space then => followed by zero or more space
    #(or) no space then : followed by one or more space
    #value (can use spaces if surrounded by single quote ('))
    #ending with 0 or 1 comma
    while /\s*(?<key>(\w+))(\s*=>|:\s+)\s*(?<value>(\w+|'[\w\s]+')),?/ =~ string_h
      hash_args[key.to_sym] = value.delete("'")
      string_h = $' # string after match
    end
    hash_args
  end

  def validateOutputArgs args
    if args.length != OutputArgs.length
      raise "Format wrong"
    end

    if args[:name] == nil
      raise "Missing name parameter"
    end

    begin 
      p args[:date]
      Date.strptime(args[:date], '%Y-%m-%d')
    rescue RuntimeError
      raise "Date format: yyyy-mm-dd"
    end

    if args[:amount] == nil
      raise "Missing amount parameter"
    end

    if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ args[:amount]
      args[:amount] = DollarFixedPt.new(dollars, cents)
    else
      args[:amount] = DollarFixedPt.new(args.amount.to_i, 0)
    end

    if args[:amount] <= DollarFixedPt.new(0, 0)
      raise "amount cannot be negative"
    end
  
    not_found = ->{ raise "category not found #{args[:category]}" }
    cats = Data.getCategoriesList
    cats.find(not_found) do |c|
      c == args[:category]
    end
    args
  end
end
