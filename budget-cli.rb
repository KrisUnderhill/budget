require_relative 'Parser'
require_relative 'Money'
require_relative 'Database'
require 'sqlite3'

db = SQLite3::Database.new "test.db"
args = Parser.parse

if args.operation == "transaction"
  Transaction.add_transaction(args.args)

elsif args.operation == "up_trans"
  Transaction.up_transaction(args.args)

elsif args.operation == "rm_trans"
  Transaction.rm_transaction(args.args[:id])

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
  amt_by_cat = {}
  Account.getAccountList.each { |e| amt_by_cat[e] = DollarFixedPt.new(0,0)}
  db.execute "SELECT * FROM transactions WHERE date BETWEEN (?) AND (?)", [date_begin, date_end] do |row|
    dollars = row[3]
    cents = row[4]
    cat = row[5]
    amt_by_cat[cat] += DollarFixedPt.new(dollars,cents)
  end

  # print
  total = DollarFixedPt.new(0,0)
  amt_by_cat.each do |c, amt| 
    puts "#{c}: #{amt}"
    total += amt
  end
  puts "Total: #{total}"

elsif args.operation == "recent"
  type = args.args[:type]
  date_begin = args.args[:range_start]
  date_end = args.args[:range_end]
  if type.casecmp("limit") == 0
    rows = db.execute "SELECT rowid, * FROM transactions ORDER BY date DESC LIMIT (?)", args.args[:num]
  elsif type.casecmp("month") == 0
    today = Date.today
    month = today.month
    year = today.year
    date_begin = Date.new(year, month, 1).strftime("%Y-%m-%d") #first day of month
    date_end = Date.new(year, month+1, 1).prev_day.strftime("%Y-%m-%d")
    rows = db.execute "SELECT rowid, * FROM transactions WHERE date BETWEEN (?) AND (?) ORDER BY date DESC", [date_begin, date_end]
  elsif type.casecmp("date") == 0
    if date_end == nil
      date_end = Date.today.strftime("%Y-%m-%d")
    end
    rows = db.execute "SELECT * FROM transactions WHERE date BETWEEN (?) AND (?) ORDER BY date DESC", [date_begin, date_end]
  end


  puts " rowid | name | date | desc | amount | cat "
  rows.each do |row|
    rowid = row[0]
    name = row[1]
    date = row[2]
    desc = row[3]
    amount = DollarFixedPt.new(row[4], row[5])
    cat = row[6]
    puts "#{rowid} | #{name} | #{date} | #{desc} | #{amount} | #{cat} "
  end

elsif args.operation == "input"
  name = args.args[:name]
  date = args.args[:date]
  distribution = ""
  args.args.each_pair do |key, value|
    next if Arguments.get_input_args.include? key.to_s
    distribution << "#{key}: #{value}, "
  end
  distribution.delete_suffix!(", ")
  db.execute "INSERT INTO inputs VALUES (?, ?, ?)", 
    [name, date, distribution]

elsif args.operation == "add_account"
  name = args.args[:name]
  type = args.args[:type]
  balance = args.args[:balance]
  target = args.args[:target]
  db.execute "INSERT INTO accounts VALUES (?, ?, ?, ?, ?, ?)", 
    [name, type, balance.dollars, balance.cents, target.dollars, target.cents]

elsif args.operation == "up_account"
  name = args.args[:name]
  type = args.args[:type]
  balance = args.args[:balance]
  target = args.args[:target]
  db.execute "UPDATE accounts SET type = (?), balance_dollars = (?), balance_cents = (?), target_dollars = (?), target_cents = (?) WHERE UPPER(name) = UPPER(?)", 
    [type, balance.dollars, balance.cents, target.dollars, target.cents, name]

elsif args.operation == "rm_account"
  name = args.args[:name]
  db.execute "DELETE FROM accounts WHERE UPPER(name) = UPPER(?)", [name]

else 
  p Database::Account.getAccountList
  p "see help menu -h"
end

