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

  def to_s
    return "$#{@dollars}.#{@cents.to_s.rjust(2, "0")}"
  end
end
