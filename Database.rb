require_relative 'Database/Account'
require_relative 'Database/Transaction'
require_relative 'Database/Input'
require_relative 'Money'

require 'sqlite3'

module Database
  #DB = SQLite3::Database.new "test2.db"
  DB = SQLite3::Database.new "test2.db"
end
