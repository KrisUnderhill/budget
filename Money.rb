class DollarFixedPtError < StandardError
  def initialize(msg="")
    super
  end
end

class DollarFixedPt
  # expected to use from_s for intialization
  # good format is "($)(-)0.00"
  attr_accessor :dollars, :cents

  def initialize(dollars, cents)
    raise DollarFixedPtError, "Bad argument to new" if (((dollars < 0) && (cents > 0)) || ((dollars > 0) && (cents < 0)))
    raise DollarFixedPtError, "Bad argument to new" if ((cents >= 100) || (cents <= -100))
    @dollars = dollars
    @cents = cents
  end

  def self.from_s(string)
    if /^\$?(?<negative>-?)(?<dollars>\d+)\.(?<cents>\d\d)$/ =~ string
      if negative == "-"
        dollars = -1 * dollars.to_i
        cents = -1 * cents.to_i
      else
        dollars = dollars.to_i
        cents = cents.to_i
      end
      return DollarFixedPt.new(dollars.to_i, cents.to_i)
    end
    raise DollarFixedPtError, "Bad argument to from_s"
  end

  def self.zero
    return DollarFixedPt.new(0,0)
  end

  def +(obj)
    raise DollarFixedPtError, "Argument not DollarFixedPt type" if obj.class != DollarFixedPt
    new_dollars = @dollars + obj.dollars
    new_cents = @cents + obj.cents
    if (new_cents >= 100) || (new_cents > 0 && new_dollars < 0)
      new_cents -= 100
      new_dollars += 1
    elsif (new_cents <= -100) || (new_cents < 0 && new_dollars > 0)
      new_cents += 100
      new_dollars -= 1
    end
    return DollarFixedPt.new(new_dollars, new_cents)
  end

  def -(obj)
    raise DollarFixedPtError, "Argument not DollarFixedPt type" if obj.class != DollarFixedPt
    new_obj = DollarFixedPt.new(-1 * obj.dollars, -1 * obj.cents)
    return self + new_obj
  end

  def >(obj)
    return greater(obj)
  end
  def >=(obj)
    return (greater(obj) || equal(obj))
  end
  def <=(obj)
    return !greater(obj)
  end
  def <(obj)
    return !(greater(obj) || equal(obj))
  end
  def ==(obj)
    return equal(obj)
  end
  def !=(obj)
    return !equal(obj)
  end

  def to_s
    neg = self < DollarFixedPt.zero ? "-" : ""
    dollars = @dollars.abs
    cents = @cents.abs
    return "$#{neg}#{dollars}.#{cents.to_s.rjust(2, "0")}"
  end
  
  private
  def equal(obj)
    if obj.class != DollarFixedPt
      raise DollarFixedPtError, "Argument not DollarFixedPt type"
    end
    return @dollars == obj.dollars && @cents == obj.cents
  end
  def greater(obj)
    if obj.class != DollarFixedPt
      raise DollarFixedPtError, "Argument not DollarFixedPt type"
    end

    result = false
    if @dollars > obj.dollars
      result = true
    elsif @dollars == obj.dollars
      if @cents > obj.cents
        result = true
      end
    end
    return result
  end
end
