require_relative 'Money'

# initialize
# good
g1 = DollarFixedPt.new(-1,0)
raise "Should allow -1,0" unless g1.dollars == -1 && g1.cents == 0
g2 = DollarFixedPt.new(0,-1)
raise "Should allow 0,-1" unless g2.dollars == 0 && g2.cents == -1
g3 = DollarFixedPt.new(-10,-10)
raise "Should allow -10,-10" unless g3.dollars == -10 && g3.cents == -10
g4 = DollarFixedPt.new(50,75)
raise "Should allow 50,75" unless g4.dollars == 50 && g4.cents == 75 

# bad
begin
b1  = DollarFixedPt.new(0,100)
raise "Should not allow 0, 100"
rescue DollarFixedPtError 
end
begin
b2  = DollarFixedPt.new(0,-100)
raise "Should not allow 0, -100"
rescue DollarFixedPtError 
end
begin
b3  = DollarFixedPt.new(-10,10)
raise "Should not allow -10, 10"
rescue DollarFixedPtError 
end
begin
b4  = DollarFixedPt.new(-10,10)
raise "Should not allow -10, 10"
rescue DollarFixedPtError 
end

# from_s
g5 = DollarFixedPt.from_s("591.01")
raise "Should allow 591.01" unless g5.dollars == 591 && g5.cents == 1 
g6 = DollarFixedPt.from_s("$0.95")
raise "Should allow $0.95" unless g6.dollars == 0 && g6.cents == 95 
g7 = DollarFixedPt.from_s("00.50")
raise "Should allow 00.50" unless g7.dollars == 0 && g7.cents == 50 
g8 = DollarFixedPt.from_s("$-123.95")
raise "Should allow -123.95" unless g8.dollars == -123 && g8.cents == -95 
g9 = DollarFixedPt.from_s("$0.00")
raise "Should allow $0.00" unless g9.dollars == 0 && g9.cents == 0 

# bad
begin
b5  = DollarFixedPt.from_s("10.-1")
raise "Should not allow 10.-1"
rescue DollarFixedPtError 
end
begin
b6  = DollarFixedPt.from_s("11.005")
raise "Should not allow 11.005"
rescue DollarFixedPtError 
end
begin
b7  = DollarFixedPt.from_s("11.500")
raise "Should not allow 11.500"
rescue DollarFixedPtError 
end
begin
b8  = DollarFixedPt.from_s("10")
raise "Should not allow 10"
rescue DollarFixedPtError 
end
begin
b9  = DollarFixedPt.from_s(".99")
raise "Should not allow 10"
rescue DollarFixedPtError 
end
begin
b10 = DollarFixedPt.from_s("0")
raise "Should not allow 10"
rescue DollarFixedPtError 
end
begin
b11 = DollarFixedPt.from_s("$0")
raise "Should not allow 10"
rescue DollarFixedPtError 
end

# zero
zero = DollarFixedPt.zero
raise "Zero not correct value" unless zero.dollars == 0 && zero.cents == 0

# + 
first = DollarFixedPt.new(100,75)
second = DollarFixedPt.new(50,25)
third = DollarFixedPt.new(-100, -99)
forth = DollarFixedPt.new(-25, -25)
fifth = DollarFixedPt.new(59,95)
sixth = DollarFixedPt.new(-60,-99)
seventh = DollarFixedPt.new(59,99)
eigth = DollarFixedPt.from_s("$1400.00")
ninth = DollarFixedPt.from_s("$2.50")
tenth = DollarFixedPt.new(-100,0)
eleventh = DollarFixedPt.new(50,50)

begin
  first += 1
  raise "Should not allow addition of different type"
rescue DollarFixedPtError 
end
res = first + second
raise "Addition result not correct 100.75 + 50.25" unless res.dollars == 151 && res.cents == 0
res = first + third
raise "Addition result not correct 100.75 + -100.99" unless res.dollars == 0 && res.cents == -24 
res = second + third
raise "Addition result not correct 50.25 + -100.99" unless res.dollars == -50 && res.cents == -74 
res = third + first
raise "Addition result not correct -100.99 + 100.75" unless res.dollars == 0 && res.cents == -24 
res = third + second
raise "Addition result not correct -100.99 + 50.25" unless res.dollars == -50 && res.cents == -74 
res = third + forth
raise "Addition result not correct -100.99 + -25.25" unless res.dollars == -126 && res.cents == -24 
res = fifth + sixth
raise "Addition result not correct 50.95 + -60.99" unless res.dollars == -1 && res.cents == -4 
res = tenth + eleventh
raise "Addition result not correct -100.00 + 50.50" unless res.dollars == -49 && res.cents == -50 

# - 
res = first - second
raise "Subtraction result not correct 100.75 - 50.25" unless res.dollars == 50 && res.cents == 50
res = second - first
raise "Subtraction result not correct 50.25 - 100.75" unless res.dollars == -50 && res.cents == -50
res = third - forth
raise "Subtraction result not correct -100.99 - -25.25" unless res.dollars == -75 && res.cents == -74
res = forth - third
raise "Subtraction result not correct  -25.25 - -100.99" unless res.dollars == 75 && res.cents == 74
res = fifth - seventh
raise "Subtraction result not correct 50.95 - 60.99" unless res.dollars == 0 && res.cents == -4
res = eigth - ninth
raise "Subtraction result not correct 1400.00 - 2.50" unless res.dollars == 1397 && res.cents == 50 


# equal
equal1 = DollarFixedPt.new(99,99)
equal2 = DollarFixedPt.new(99,99)
equal3 = DollarFixedPt.new(-55,-55)
equal4 = DollarFixedPt.new(-55,-55)
begin
  x = (equal1 == 1)
  raise "Should error if other type is not DollarFixedPt"
rescue DollarFixedPtError
end
raise "Should be equal 99,99 == 99,99" unless equal1 == equal2
raise "Should be equal -55,-55 == -55,-55" unless equal3 == equal4
raise "Should be not equal -55,-55 == 99,99" if equal3 == equal2

# greater
greater1 = DollarFixedPt.new(111,11)
greater2 = DollarFixedPt.new(111,10)
greater3 = DollarFixedPt.new(110,11)
greater4 = DollarFixedPt.new(-11,-11)
greater5 = DollarFixedPt.new(-11,-10) 
greater6 = DollarFixedPt.new(-10,-11) 
begin
  x = (greater1 > 1)
  raise "Should error if other type is not DollarFixedPt"
rescue DollarFixedPtError
end
raise "Should be greater 111.11 > 111.10" unless greater1 > greater2
raise "Should be greater 111.11 > 110.11" unless greater1 > greater3
raise "Should be greater 110.11 > -11.11" unless greater3 > greater4
raise "Should be greater -11.10 > -11.11" unless greater5 > greater4
raise "Should be greater -10.11 > -11.11" unless greater6 > greater4
raise "Should not be greater 111.11 > 111.10" if greater2 > greater1
raise "Should not be greater 111.11 > 110.11" if greater3 > greater1
raise "Should not be greater 110.11 > -11.11" if greater4 > greater3
raise "Should not be greater -11.10 > -11.11" if greater4 > greater5
raise "Should not be greater -10.11 > -11.11" if greater4 > greater6

# to_s
printable1 = DollarFixedPt.new(123,45)
printable2 = DollarFixedPt.new(-567,-89)
printable3 = DollarFixedPt.new(632,0)
printable4 = DollarFixedPt.new(-579,-2)
raise "Should be $123.45" unless "$123.45" == printable1.to_s
raise "Should be $-567.89" unless "$-567.89" == printable2.to_s
raise "Should be $632.00" unless "$632.00" == printable3.to_s
raise "Should be $-579.02" unless "$-579.02" == printable4.to_s
