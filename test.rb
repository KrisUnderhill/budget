require_relative 'Database'
require_relative 'Money'

prng = Random.new()
db = SQLite3::Database.new "test2.db"
rows = db.execute "SELECT rowid FROM transactions ORDER BY rowid DESC LIMIT 1"
rowid = rows.flatten![0]
date = Date.today + rowid
amount = DollarFixedPt.new(rowid, 50)
up_amount = DollarFixedPt.new(rowid+100, 50)
accounts = Database::Account.getAccountList
category = accounts[prng.rand(accounts.size)]

insert_hash = { name: "test#{rowid + 1}",
                desc: "This is a test #{rowid + 1}",
                date: "#{date.strftime("%Y-%m-%d")}",
                amount: "#{amount}",
                category: category}
update_hash = { name: "test#{rowid}",
                desc: "This is a test #{rowid}",
                date: "#{date.strftime("%Y-%m-%d")}",
                amount: "#{up_amount}",
                category: category,
                id: rowid }
output_hash = { "housing": "#{DollarFixedPt.new(100,0)}"}

rows = db.execute "SELECT rowid FROM inputs ORDER BY rowid DESC LIMIT 1"
in_rowid = rows.flatten![0]
in_date = Date.today + rowid
add_input = { name: "salary",
              date: "#{in_date.strftime("%Y-%m-%d")}",
              distribution: {"emergency" => DollarFixedPt.new(123,23).to_s,
                             "car" => DollarFixedPt.new(456,56).to_s,
                             "housing" => DollarFixedPt.new(789,89).to_s }}

up_input = { name: "bonus",
             date: "#{in_date.strftime("%Y-%m-%d")}",
             distribution: {"emergency" => DollarFixedPt.new(223,23).to_s,
                            "car" => DollarFixedPt.new(556,56).to_s,
                            "housing" => DollarFixedPt.new(889,89).to_s },
             id: 5}
add_account = { name: "misc",
                type: "static",
                balance: DollarFixedPt.new(500,0),
                target: DollarFixedPt.new(100,0)}
up_account = { name: "misc",
               new_name: "misc2",
               type: "static",
               balance: DollarFixedPt.new(500,0),
               target: DollarFixedPt.new(300,0)}

p in_rowid 
#Database::Account.output output_hash
#Database::Account.addAccount add_account
#Database::Account.rmAccount "misc"
Database::Account.upAccount up_account
#Database::Transaction.addTrans insert_hash
#Database::Transaction.rmTrans rowid + 1
#Database::Transaction.upTrans update_hash
#Database::Transaction.isIdValid rowid + 1
#Database::Input.addInput add_input
#Database::Input.rmInput 5
#Database::Input.upInput up_input 
