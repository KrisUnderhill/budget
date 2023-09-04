module Database
  class Account
    ADD_DB_STRING = "INSERT INTO accounts VALUES (?, ?, ?, ?)"
    RM_DB_STRING = "DELETE FROM accounts WHERE UPPER(name)=UPPER(?)"
    UP_DB_STRING = "UPDATE accounts SET name=(?),type=(?),balance=(?),target=(?) WHERE UPPER(name)=UPPER(?)" 
    GET_NAMES_DB_STRING = "SELECT name FROM accounts".freeze
    GET_BALANCE_DB_STRING = "SELECT balance FROM accounts where UPPER(name)=UPPER((?))"
    UPDATE_BALANCE_DB_STRING = "UPDATE accounts SET balance=(?) WHERE UPPER(name) = UPPER(?)"
    SELECT_TABLE_DB_STRING = "SELECT * FROM accounts"
    def self.addAccount hash
      Database::DB.execute ADD_DB_STRING,
        [hash[:name], hash[:type], hash[:balance].to_s, hash[:target].to_s]
    end
    def self.rmAccount name
      raise "Name not found" unless isNameValid name
      Database::DB.execute RM_DB_STRING, [name]
    end
    def self.upAccount hash
      raise "Name not found" unless isNameValid hash[:name]
      Database::DB.execute UP_DB_STRING,
        [hash[:new_name], hash[:type], hash[:balance].to_s, hash[:target].to_s, hash[:name]]
    end
    def self.getAccountList
      names = Database::DB.execute GET_NAMES_DB_STRING
      names.flatten!.each { |name| name.upcase!.freeze }
      return names
    end
    def self.output hash
      hash.each do |name, amount|
        balance = getAccountBalance(name.to_s)
        balance -= DollarFixedPt.from_s(amount)
        Database::DB.execute UPDATE_BALANCE_DB_STRING, [balance.to_s, name.to_s]
      end
    end

    def self.input hash
      hash.each do |name, amount|
        balance = getAccountBalance(name.to_s)
        balance += DollarFixedPt.from_s(amount)
        Database::DB.execute UPDATE_BALANCE_DB_STRING, [balance.to_s, name.to_s]
      end
    end

    def self.getTable
      return Database::DB.execute SELECT_TABLE_DB_STRING
    end

    private
    def self.getAccountBalance name
      balance = Database::DB.execute GET_BALANCE_DB_STRING, [name]
      return DollarFixedPt.from_s(balance.flatten[0])
    end
    def self.isNameValid name
      found = true
      not_found = ->{ found = false }
      accounts = getAccountList
      accounts.find(not_found) do |a|
        a.casecmp(name) == 0
      end
      found
    end
  end
end
