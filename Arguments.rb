require_relative 'Money'
require_relative 'Data'

class Arguments
  attr_accessor :operation, :args
  @@Operations = %w[output input breakdown list]
  @@OutputArgs = %w[name date desc amount category]
  @@BreakdownTypes = %w[month custom] #6m year ytd custom]
  @@BreakdownArgs = %w[type range_start range_end]

  def initialize
    @operation = nil 
    @args = {}
  end

  def set_output args
    @operation = "output"
    @args = validateOutputArgs args
    nil
  end

  def set_breakdown args
    @operation = "breakdown"
    @args = validateBreakdownArgs args
    nil
  end

  private 
  def validateBreakdownArgs args
    not_found = ->{ raise "type not found #{args[:type]}" }
    @@BreakdownTypes.find(not_found) do |t|
      t.casecmp(args[:type]) == 0 #same string case insensitive
    end

    if "custom".casecmp(args[:type]) == 0
      if args[:range_start] == nil
        raise "range_start param required for custom type"
      end
      begin 
        Date.strptime(args[:range_start], '%Y-%m-%d')
      rescue RuntimeError
        raise "Date format: yyyy-mm-dd"
      end
      if args[:range_end] != nil
        begin 
          Date.strptime(args[:range_end], '%Y-%m-%d')
        rescue RuntimeError
          raise "Date format: yyyy-mm-dd"
        end
      end
    end
    args
  end

  def validateOutputArgs args
    if args.length != @@OutputArgs.length
      raise "Format wrong"
    end

    if args[:name] == nil
      raise "Missing name parameter"
    end

    begin 
      Date.strptime(args[:date], '%Y-%m-%d')
    rescue RuntimeError
      raise "Date format: yyyy-mm-dd"
    end

    if args[:amount] == nil
      raise "Missing amount parameter"
    end

    if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ args[:amount]
      args[:amount] = DollarFixedPt.new(dollars.to_i, cents.to_i)
    else
      args[:amount] = DollarFixedPt.new(args[:amount].to_i, 0)
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
