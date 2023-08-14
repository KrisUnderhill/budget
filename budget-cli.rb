require_relative 'Parser'
require_relative 'Money'
require 'sqlite3'

db = SQLite3::Database.new "test.db"
args = Parser.parse

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
#elsif options.recent
#  rows = db.execute "SELECT * FROM transactions"
#  args = validateRecentArgs
#  row_count = 0 
#
#  puts " name | date | desc | amount | cat "
#  rows.reverse_each do |row|
#    name = row[0]
#    date = row[1]
#    desc = row[2]
#    amount = DollarFixedPt.new(row[3], row[4])
#    cat = row[5]
#    puts " #{name} | #{date} | #{desc} | #{amount} | #{cat} "
#    row_count += 1
#    break if row_count >= args.limit
#  end
else 
  p "see help menu -h"
end


