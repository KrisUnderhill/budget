module Database
  class Input
    ADD_DB_STRING = "INSERT INTO inputs VALUES (?, ?, ?)"
    RM_DB_STRING = "DELETE FROM inputs WHERE rowid=(?)"
    UP_DB_STRING = "UPDATE inputs SET name=(?),date=(?),distribution=(?) WHERE rowid=(?)" 
    SELECT_DB_STRING = "SELECT distribution FROM inputs WHERE rowid=(?)"
    SELECT_RECENT_LIMIT_STRING = "SELECT rowid, * FROM inputs ORDER BY date DESC LIMIT (?)"
    SELECT_RECENT_DATE_STRING = "SELECT rowid, * FROM inputs WHERE date BETWEEN (?) AND (?) ORDER BY date DESC"

    def self.addInput hash
      Database::DB.execute ADD_DB_STRING,
        [hash[:name], hash[:date], hash[:distribution].to_s]
      Database::Account.input(hash[:distribution])
    end
  
    def self.rmInput id
      raise "Invalid input id" unless isIdValid(id)
      undoInput id
      Database::DB.execute RM_DB_STRING, [id]
    end
  
    def self.upInput hash
      raise "Invalid input id" unless isIdValid(hash[:id])
      undoInput hash[:id]
      Database::DB.execute UP_DB_STRING,
        [hash[:name], hash[:date], hash[:distribution].to_s, hash[:id]]
      Database::Account.input(hash[:distribution])
    end
  
    def self.isIdValid id
      row = Database::DB.execute SELECT_DB_STRING, [id]
      return row.size > 0
    end

    def self.recentByLimit num
      rows = Database::DB.execute SELECT_RECENT_LIMIT_STRING, num
      rows.each { |row| row[3] = parseDistribution row[3]}
      return rows
    end

    def self.recentByDate date_begin, date_end
      rows = Database::DB.execute SELECT_RECENT_DATE_STRING, [date_begin, date_end]
      rows.each { |row| row[3] = parseDistribution row[3]}
      return rows
    end

    private 
    def self.undoInput id
      row = Database::DB.execute SELECT_DB_STRING, [id]
      row.flatten!
      dist = parseDistribution row[0]
      Database::Account.output(dist)
    end
    def self.parseDistribution string
      hash = {}
      #zero or more spaces at beginning
      #"key"
      #zero or more space then => followed by zero or more space
      #(or) no space then : followed by one or more space
      #value (can use spaces if surrounded by single quote (')
      #ending with 0 or 1 comma
      while /\s*(?<key>(:\w+|\"\w+\"))=>(?<value>(\"[\w.\$-]*\")),?/ =~ string
        hash[key.delete(":\"").to_sym] = value.delete("\"")
        string = $' # string after match
      end
      hash
    end
  end
end
