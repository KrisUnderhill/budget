require_relative 'Parser'
require_relative 'Money'
require 'sqlite3'

db = SQLite3::Database.new "test.db"
args = Parser.parse

if args.operation == "output"
  db.execute "INSERT INTO transactions VALUES (?, ?, ?, ?, ?, ?)", 
    [args.args[:name], args.args[:date], args.args[:desc], args.args[:amount].dollars, args.args[:amount].cents, args.args[:category]]
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
  Data.getCategoriesList.each { |e| amt_by_cat[e] = DollarFixedPt.new(0,0)}
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
    rows = db.execute "SELECT * FROM transactions ORDER BY date DESC LIMIT (?)", args.args[:num]
  elsif type.casecmp("month") == 0
    today = Date.today
    month = today.month
    year = today.year
    date_begin = Date.new(year, month, 1).strftime("%Y-%m-%d") #first day of month
    date_end = Date.new(year, month+1, 1).prev_day.strftime("%Y-%m-%d")
    rows = db.execute "SELECT * FROM transactions WHERE date BETWEEN (?) AND (?) ORDER BY date DESC", [date_begin, date_end]
  elsif type.casecmp("date") == 0
    if date_end == nil
      date_end = Date.today.strftime("%Y-%m-%d")
    end
    rows = db.execute "SELECT * FROM transactions WHERE date BETWEEN (?) AND (?) ORDER BY date DESC", [date_begin, date_end]
  end


  puts " name | date | desc | amount | cat "
  rows.each do |row|
    name = row[0]
    date = row[1]
    desc = row[2]
    amount = DollarFixedPt.new(row[3], row[4])
    cat = row[5]
    puts " #{name} | #{date} | #{desc} | #{amount} | #{cat} "
  end
else 
  p "see help menu -h"
end


