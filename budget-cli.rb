require_relative 'Parser'
require_relative 'Money'
require_relative 'Database'
require 'sqlite3'

db = SQLite3::Database.new "test.db"
args = Parser.parse

if args.operation == "transaction"
  Database::Transaction.addTrans(args.args)

elsif args.operation == "up_trans"
  Database::Transaction.upTrans(args.args)

elsif args.operation == "rm_trans"
  Database::Transaction.rmTrans(args.args[:id])

elsif args.operation == "input"
  Database::Input.addInput(args.args)
  
elsif args.operation == "rm_input"
  Database::Input.rmInput(args.args[:id])

elsif args.operation == "up_input"
  Database::Input.upInput(args.args)

elsif args.operation == "add_account"
  Database::Account.addAccount(args.args)

elsif args.operation == "up_account"
  Database::Account.upAccount(args.args)

elsif args.operation == "rm_account"
  Database::Account.rmAccount(args.args[:name])

elsif args.operation == "breakdown"
  # set date range by type
  type = args.args[:type]
  date_begin = args.args[:range_start]
  date_end = args.args[:range_end]
  if type.casecmp("month") == 0
    today = Date.today
    month = today.month
    year = today.year
    date_begin = Date.new(year, month, 1).strftime("%Y-%m-%d") #first day of month
    date_end = Date.new(year, month+1, 1).prev_day.strftime("%Y-%m-%d")
  elsif type.casecmp("custom") == 0
    if date_end == nil
      date_end = Date.today.strftime("%Y-%m-%d")
    end
  end

  # execute query
  out_by_acc = {}
  in_by_acc = {}
  Database::Account.getAccountList.each { |e| out_by_acc[e] = DollarFixedPt.zero}
  Database::Account.getAccountList.each { |e| in_by_acc[e] = DollarFixedPt.zero}
  recent_out = Database::Transaction.recentByDate(date_begin, date_end)
  recent_out.each do |row|
    acc = row[5].upcase
    amount = DollarFixedPt.from_s(row[4])
    if out_by_acc[acc] == nil
      out_by_acc[acc] = amount
    else
      out_by_acc[acc] += amount
    end
  end
  recent_in = Database::Input.recentByDate(date_begin, date_end)
  recent_in.each do |row|
    distribution = row[3]
    distribution.each do |acc, amount|
      acc = acc.to_s.upcase
      amount = DollarFixedPt.from_s amount
      if in_by_acc[acc] == nil
        in_by_acc[acc] = amount
      else
        in_by_acc[acc] += amount
      end
    end
  end

  # print
  out_total = DollarFixedPt.zero
  puts "Outputs"
  out_by_acc.each do |c, amt| 
    puts "#{c}: #{amt}"
    out_total += amt
  end
  puts "Total: #{out_total}"

  puts "\n"

  in_total = DollarFixedPt.zero
  puts "Inputs"
  in_by_acc.each do |c, amt| 
    puts "#{c}: #{amt}"
    in_total += amt
  end
  puts "Total: #{in_total}"


elsif args.operation == "recent"
  type = args.args[:type]
  date_begin = args.args[:range_start]
  date_end = args.args[:range_end]
  if type.casecmp("limit") == 0
    recents = Database::Transaction.recentByLimit args.args[:num]
  elsif type.casecmp("month") == 0
    today = Date.today
    month = today.month
    year = today.year
    date_begin = Date.new(year, month, 1).strftime("%Y-%m-%d") #first day of month
    date_end = Date.new(year, month+1, 1).prev_day.strftime("%Y-%m-%d")
    recents = Database::Transaction.recentByDate(date_begin, date_end)
  elsif type.casecmp("date") == 0
    if date_end == nil
      date_end = Date.today.strftime("%Y-%m-%d")
    end
    recents = Database::Transaction.recentByDate(date_begin, date_end)
  end

  puts " rowid | name | date | desc | amount | account "
  recents.each do |row|
    rowid = row[0]
    name = row[1]
    date = row[2]
    desc = row[3]
    amount = DollarFixedPt.from_s(row[4])
    acc = row[5].upcase
    puts "#{rowid} | #{name} | #{date} | #{desc} | #{amount} | #{acc} "
  end

elsif args.operation == "list_accounts"
  account_table = Database::Account.getTable

  puts " name | type | balance | target "
  account_table.each do |account|
    name = account[0].upcase
    type = account[1].upcase
    balance = DollarFixedPt.from_s(account[2])
    target = DollarFixedPt.from_s(account[3])
    puts "#{name} | #{type} | #{balance} | #{target}"
  end

elsif args.operation == "input_recent"
  type = args.args[:type]
  date_begin = args.args[:range_start]
  date_end = args.args[:range_end]
  if type.casecmp("limit") == 0
    recents = Database::Input.recentByLimit args.args[:num]
  elsif type.casecmp("month") == 0
    today = Date.today
    month = today.month
    year = today.year
    date_begin = Date.new(year, month, 1).strftime("%Y-%m-%d") #first day of month
    date_end = Date.new(year, month+1, 1).prev_day.strftime("%Y-%m-%d")
    recents = Database::Input.recentByDate(date_begin, date_end)
  elsif type.casecmp("date") == 0
    if date_end == nil
      date_end = Date.today.strftime("%Y-%m-%d")
    end
    recents = Database::Input.recentByDate(date_begin, date_end)
  end

  puts "rowid | name | date | distribution "
  recents.each do |row|
    rowid = row[0]
    name = row[1]
    date = row[2]
    dist = row[3]
    puts "#{rowid} | #{name} | #{date} | #{dist}"
  end


else 
  p "see help menu -h"
end

