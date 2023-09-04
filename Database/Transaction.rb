module Database
  class Transaction
    ADD_DB_STRING = "INSERT INTO transactions VALUES (?, ?, ?, ?, ?)"
    RM_DB_STRING = "DELETE FROM transactions WHERE rowid=(?)"
    UP_DB_STRING = "UPDATE transactions SET name=(?),desc=(?),date=(?),amount=(?),category=(?) WHERE rowid=(?)" 
    SELECT_DB_STRING = "SELECT category,amount FROM transactions WHERE rowid=(?)"
    SELECT_RECENT_LIMIT_STRING = "SELECT rowid, * FROM transactions ORDER BY date DESC LIMIT (?)"
    SELECT_RECENT_DATE_STRING = "SELECT rowid, * FROM transactions WHERE date BETWEEN (?) AND (?) ORDER BY date DESC"

    def self.addTrans hash
      Database::DB.execute ADD_DB_STRING,
        [hash[:name], hash[:desc],
         hash[:date], hash[:amount].to_s,
         hash[:account]]
      p hash[:amount].to_s
      Database::Account.output({hash[:account]=>hash[:amount].to_s})
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
         hash[:account], hash[:id]]
      Database::Account.output({hash[:account]=>hash[:amount].to_s})
    end
  
    def self.isIdValid id
      row = Database::DB.execute SELECT_DB_STRING, [id]
      return row.size > 0
    end

    def self.recentByLimit num
      rows = Database::DB.execute SELECT_RECENT_LIMIT_STRING, num
      return rows
    end

    def self.recentByDate date_begin, date_end
      rows = Database::DB.execute SELECT_RECENT_DATE_STRING, [date_begin, date_end]
    end

    private 
    def self.undoTrans id
      row = Database::DB.execute SELECT_DB_STRING, [id]
      row.flatten!
      p row
      Database::Account.input({row[0]=>row[1]})
    end
  end
end
