require_relative 'Money'
require_relative 'Data'

class Arguments
  attr_accessor :operation, :args
  @@Operations = %w[output input breakdown list add_account up_account rm_account up_trans rm trans]
  @@OutputArgs = %w[name date desc amount category]
  @@BreakdownTypes = %w[month custom] #6m year ytd custom]
  @@BreakdownArgs = %w[type range_start range_end]
  @@RecentTypes = %w[limit month date] 
  @@RecentArgs = %w[type num range_start range_end]
  @@InputArgs = %w[name date total] #also any category/account
  @@AccountTypes = %w[revolving static]

  def initialize
    @operation = nil 
    @args = {}
  end

  def self.get_input_args 
    @@InputArgs
  end

  def set_output args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "output"
    @args = validateOutputArgs args
    nil
  end

  def set_breakdown args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "breakdown"
    @args = validateBreakdownArgs args
    nil
  end

  def set_recent args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "recent"
    @args = validateRecentArgs args
    nil
  end

  def set_input args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "input"
    @args = validateInputArgs args
    nil
  end

  def set_add_account args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "add_account"
    @args = validateAccountChangeArgs args
    nil
  end

  def set_up_account args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "up_account"
    @args = validateAccountChangeArgs args
    nil
  end

  def set_rm_account name
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "rm_account"
    not_found = ->{ raise "account not found #{args[:account]}" }
    cats = Data.getCategoriesList
    cats.find(not_found) do |c|
      c == name
    end
    @args[:name] = name
    nil
  end

  def set_up_trans args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "up_trans"
    @args = validateUpTransArgs args
    nil
  end

  def set_rm_trans id
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "rm_trans"
    raise "Cannot find id" unless Data.isIdValid id
    @args[:id] = id
    nil
  end

  private 
  def validateUpTransArgs args
    raise "id arg not found" if args[:id] == nil
    id = args[:id]
    args.delete(:id)
    args = validateOutputArgs(args)
    args[:id] = id
    args
  end

  def validateAccountChangeArgs args
    raise "name arg not found" if args[:name] == nil
    raise "Type arg not found" if args[:type] == nil
    not_found = ->{ raise "type not found #{args[:type]}" }
    @@AccountTypes.find(not_found) do |t|
      t.casecmp(args[:type]) == 0 #same string case insensitive
    end

    raise "balance arg not found" if args[:balance] == nil
    if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ args[:balance]
      args[:balance] = DollarFixedPt.new(dollars.to_i, cents.to_i)
    else
      args[:balance] = DollarFixedPt.new(args[:balance].to_i, 0)
    end

    if args[:balance] < DollarFixedPt.new(0, 0)
      raise "balance cannot be negative"
    end

    raise "target arg not found" if args[:target] == nil
    if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ args[:target]
      args[:target] = DollarFixedPt.new(dollars.to_i, cents.to_i)
    else
      args[:target] = DollarFixedPt.new(args[:target].to_i, 0)
    end

    if args[:target] <= DollarFixedPt.new(0, 0)
      raise "target cannot be negative"
    end
    args
  end

  def validateInputArgs args
    raise "name arg not found" if args[:name] == nil
    raise "date arg not found" if args[:date] == nil
    begin 
      Date.strptime(args[:date], '%Y-%m-%d')
    rescue RuntimeError
      raise "Date format: yyyy-mm-dd"
    end

    raise "total arg not found" if args[:total] == nil
    if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ args[:total]
      args[:total] = DollarFixedPt.new(dollars.to_i, cents.to_i)
    else
      args[:total] = DollarFixedPt.new(args[:total].to_i, 0)
    end

    if args[:total] <= DollarFixedPt.new(0, 0)
      raise "total cannot be negative"
    end

    sum = DollarFixedPt.new(0, 0) 
    cats = Data.getCategoriesList
    input_cats = args.keys.delete_if {|elem| @@InputArgs.include? elem.to_s }
    input_cats.each do |cat|
      not_found = ->{ raise "category not found #{cat}" }
      cats.find(not_found) do |c|
        c == cat.to_s
      end
      if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ args[cat]
        args[cat] = DollarFixedPt.new(dollars.to_i, cents.to_i)
      else
        args[cat] = DollarFixedPt.new(args[cat].to_i, 0)
      end

      if args[cat] <= DollarFixedPt.new(0, 0)
        raise "amount cannot be negative"
      end

      sum += args[cat]
    end
    raise "Total must equal sum of category amounts" unless args[:total] == sum
    args
  end

  def validateRecentArgs args
    if args[:type] == nil
      raise "Type arg not found"
    end
    not_found = ->{ raise "type not found #{args[:type]}" }
    @@RecentTypes.find(not_found) do |t|
      t.casecmp(args[:type]) == 0 #same string case insensitive
    end

    if "limit".casecmp(args[:type]) == 0
      raise "num param required for custom type" if args[:num] == nil
      raise "num must be greater than 0" unless args[:num].to_i > 0
      args[:num] = args[:num].to_i
    end

    if "date".casecmp(args[:type]) == 0
      raise "range_start param required for date type" if args[:range_start] == nil
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

  def validateBreakdownArgs args
    if args[:type] == nil
      raise "Type arg not found"
    end
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
