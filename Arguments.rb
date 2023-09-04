require_relative 'Money'
require_relative 'Database'

class Arguments
  attr_accessor :operation, :args
  @@Operations = %w[transaction input breakdown list add_account up_account rm_account up_trans rm trans]
  @@OutputArgs = %w[name date desc amount account]
  @@BreakdownTypes = %w[month custom] #6m year ytd custom]
  @@BreakdownArgs = %w[type range_start range_end]
  @@RecentTypes = %w[limit month date] 
  @@RecentArgs = %w[type num range_start range_end]
  @@InputArgs = %w[name date] #also any account
  @@UpInputArgs = %w[name date id] #also any account
  @@AccountTypes = %w[revolving static]

  def initialize
    @operation = nil 
    @args = {}
  end

  def self.get_input_args 
    @@InputArgs
  end

  def set_transaction args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "transaction"
    @args = validateTransaction args
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
    raise "Cannot find id" unless Database::Transaction.isIdValid id
    @args[:id] = id
    nil
  end

  def set_input args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "input"
    @args = validateInputArgs args
    nil
  end

  def set_rm_input id
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "rm_input"
    raise "id not valid" unless Database::Input.isIdValid id
    @args[:id] = id
    nil
  end

  def set_up_input args
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "up_input"
    @args = validateUpInputArgs args
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
    accs = Database::Account.getAccountList
    accs.find(not_found) do |a|
      name.casecmp(a) == 0
    end
    @args[:name] = name
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

  def set_list_accounts
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "list_accounts"
    @args = {}
    nil
  end

  def set_recent_inputs args 
    raise "Cannot set arguments for multiple operations" unless @operation == nil
    @operation = "input_recent"
    @args = validateRecentArgs args
    nil
  end

  private 
  def validateUpTransArgs args
    raise "id arg not found" if args[:id] == nil
    id = args[:id]
    args.delete(:id)
    args = validateTransaction(args)
    args[:id] = id
    args
  end

  def validateAccountChangeArgs args
    raise "name arg not found" if args[:name] == nil
    args[:new_name] = args[:name] if args[:new_name] == nil
    raise "Type arg not found" if args[:type] == nil
    not_found = ->{ raise "type not found #{args[:type]}" }
    @@AccountTypes.find(not_found) do |t|
      t.casecmp(args[:type]) == 0 #same string case insensitive
    end

    raise "balance arg not found" if args[:balance] == nil
    args[:balance] = DollarFixedPt.from_s(args[:balance])
    raise "balance cannot be negative" if args[:balance] < DollarFixedPt.new(0, 0)

    raise "target arg not found" if args[:target] == nil
    args[:target] = DollarFixedPt.from_s(args[:target])
    raise "target cannot be negative" if args[:target] <= DollarFixedPt.new(0, 0)
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

    accounts = Database::Account.getAccountList
    distribution = args.select { |key,value| !@@InputArgs.include? key.to_s }
    args = args.select { |key,value| @@InputArgs.include? key.to_s }
    distribution.keys.each do |acc|
      not_found = ->{ raise "account not found #{acc}" }
      accounts.find(not_found) do |a|
        a.casecmp(acc.to_s) == 0
      end
      amount = DollarFixedPt.from_s(distribution[acc])
      raise "amount cannot be negative" if amount <= DollarFixedPt.zero
    end
    args[:distribution] = distribution
    args
  end

  def validateUpInputArgs args
    raise "id arg not found" if args[:id] == nil
    raise "id not valid" unless Database::Input.isIdValid args[:id]
    raise "name arg not found" if args[:name] == nil
    raise "date arg not found" if args[:date] == nil
    begin 
      Date.strptime(args[:date], '%Y-%m-%d')
    rescue RuntimeError
      raise "Date format: yyyy-mm-dd"
    end
    accounts = Database::Account.getAccountList
    distribution = args.select { |key,value| !@@UpInputArgs.include? key.to_s }
    args = args.select { |key,value| @@UpInputArgs.include? key.to_s }
    distribution.keys.each do |acc|
      not_found = ->{ raise "account not found #{acc}" }
      accounts.find(not_found) do |a|
        a.casecmp(acc.to_s) == 0
      end
      amount = DollarFixedPt.from_s(distribution[acc])
      raise "amount cannot be negative" if amount <= DollarFixedPt.zero
    end
    args[:distribution] = distribution
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

  def validateTransaction args
    raise "Missing name parameter" if args[:name] == nil
    raise "Missing date parameter" if args[:date] == nil
    raise "Missing desc parameter" if args[:desc] == nil

    begin 
      Date.strptime(args[:date], '%Y-%m-%d')
    rescue RuntimeError
      raise "Date format: yyyy-mm-dd"
    end

    raise "Missing amount parameter" if args[:amount] == nil
    args[:amount] = DollarFixedPt.from_s(args[:amount])
    if args[:amount] <= DollarFixedPt.zero
      raise "amount cannot be negative"
    end
  
    raise "Missing account parameter" if args[:account] == nil
    not_found = ->{ raise "account not found #{args[:account]}" }
    accs = Database::Account.getAccountList
    accs.find(not_found) do |a|
      args[:account].casecmp(a) == 0
    end
    args
  end
end
