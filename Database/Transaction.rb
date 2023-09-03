module Database
  class Transaction
    ADD_DB_STRING = "INSERT INTO transactions VALUES (?, ?, ?, ?, ?)"
    RM_DB_STRING = "DELETE FROM transactions WHERE rowid=(?)"
    UP_DB_STRING = "UPDATE transactions SET name=(?),desc=(?),date=(?),amount=(?),category=(?) WHERE rowid=(?)" 
    SELECT_DB_STRING = "SELECT category,amount FROM transactions WHERE rowid=(?)"
    def self.addTrans hash
      Database::DB.execute ADD_DB_STRING,
        [hash[:name], hash[:desc],
         hash[:date], hash[:amount].to_s,
         hash[:category]]
      Database::Account.output({hash[:category]=>hash[:amount]})
    end
  
    def self.rmTrans id
      raise "Invalid transaction id" unless isIdValid(id)
      undoTrans id
      Database::DB.execute RM_DB_STRING, [id]
    end
  
    def self.upTrans hash
      raise "Invalid transaction id" unless isIdValid(hash[:id])
      undoTrans hash[:id]
      Database::DB.execute UP_DB_STRING,
        [hash[:name], hash[:desc],
         hash[:date], hash[:amount].to_s,
         hash[:category], hash[:id]]
      Database::Account.output({hash[:category]=>hash[:amount]})
    end
  
    def self.isIdValid id
      row = Database::DB.execute SELECT_DB_STRING, [id]
      return row.size > 0
    end

    private 
    def self.undoTrans id
      row = Database::DB.execute SELECT_DB_STRING, [id]
      row.flatten!
      Database::Account.input({row[0]=>row[1]})
    end
  end
end
