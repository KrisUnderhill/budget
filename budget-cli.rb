require_relative 'Parser'
require_relative 'Money'
require 'sqlite3'

InsertArgs = Struct.new(:name, :date, :description, :amount_dollars, :amount_cents, :category)
BreakdownArgs = Struct.new(:date_begin, :date_end)
RecentArgs = Struct.new(:limit)
CATEGORIES = ["housing", "car", "food", "misc", "giving", "fun"] 

db = SQLite3::Database.new "test.db"
options = Parser.parse

def validateInsertArgs
  insertargs = InsertArgs.new()
  if ARGV.length != (insertargs.length - 1) # We split amount into two for InsertArgs
    raise "Format wrong"
  end
  name = ARGV[0]
  date = ARGV[1]
  desc = ARGV[2]
  amount = ARGV[3]
  category = ARGV[4]

  insertargs.name = name
  begin 
    Date.strptime(date, '%Y-%m-%d')
  rescue RuntimeError
    raise "Date format: yyyy-mm-dd"
  else
    insertargs.date = date
  end
  insertargs.description = desc
  if /(?<dollars>\d+)\.(?<cents>\d+)/ =~ amount
    insertargs.amount_dollars = dollars
    insertargs.amount_cents = cents
  else
    insertargs.amount_dollars = amount.to_i
    insertargs.amount_cents = 0
  end

  not_found = ->{ raise "category not found #{category}" }
  CATEGORIES.find(not_found) do |c|
    c == category
  end
  insertargs.category = category
  insertargs
end

def validateBreakdownArgs
  breakargs = BreakdownArgs.new()
  if ARGV.length != breakargs.length
    raise "Format wrong"
  end
  date_begin = ARGV[0]
  date_end = ARGV[1]
  begin 
    Date.strptime(date_begin, '%Y-%m-%d')
    Date.strptime(date_end, '%Y-%m-%d')
  rescue RuntimeError
    raise "Date format: yyyy-mm-dd"
  else
    breakargs.date_begin = date_begin
    breakargs.date_end = date_end
  end
  breakargs
end

def validateRecentArgs
  recentargs = RecentArgs.new()
  if ARGV.length != recentargs.length
    raise "Format wrong"
  end
  limit = ARGV[0].to_i
  if limit > 0
    recentargs.limit = limit
  else
    raise "Enter limit > 0"
  end
  recentargs
end

if options.insert
  args = validateInsertArgs
  db.execute "INSERT INTO transactions VALUES (?, ?, ?, ?, ?, ?)", [args.name, args.date, args.description, args.amount_dollars, args.amount_cents, args.category]
elsif options.breakdown
  args = validateBreakdownArgs
  amt_by_cat = {}
  CATEGORIES.each { |e| amt_by_cat[e] = DollarFixedPt.new(0,0)}
  db.execute "SELECT * FROM transactions WHERE date BETWEEN (?) AND (?)", [args.date_begin, args.date_end] do |row|
    dollars = row[3]
    cents = row[4]
    cat = row[5]
    amt_by_cat[cat] += DollarFixedPt.new(dollars,cents)
  end
  total = DollarFixedPt.new(0,0)
  amt_by_cat.each do |c, amt| 
    puts "#{c}: #{amt}"
    total += amt
  end
  puts "Total: #{total}"
elsif options.recent
  rows = db.execute "SELECT * FROM transactions"
  args = validateRecentArgs
  row_count = 0 

  puts " name | date | desc | amount | cat "
  rows.reverse_each do |row|
    name = row[0]
    date = row[1]
    desc = row[2]
    amount = DollarFixedPt.new(row[3], row[4])
    cat = row[5]
    puts " #{name} | #{date} | #{desc} | #{amount} | #{cat} "
    row_count += 1
    break if row_count >= args.limit
  end
else 
  p "see help menu -h"
end


