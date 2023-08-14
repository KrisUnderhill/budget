class DollarFixedPt
  attr_accessor :dollars, :cents

  def initialize(dollars, cents)
    @dollars = dollars
    @cents = cents
  end

  def +(obj)
    @cents += obj.cents
    if(@cents >= 100)
      @cents -= 100
      @dollars += 1
    end
    @dollars += obj.dollars
    return DollarFixedPt.new(@dollars, @cents)
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
    return "$#{@dollars}.#{@cents.to_s.rjust(2, "0")}"
  end
  
  private
  def equal(obj)
    return @dollars == obj.dollars && @cents == obj.cents
  end
  def greater(obj)
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
