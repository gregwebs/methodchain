require File.dirname(__FILE__) + '/../lib/methodchain'

def test_then_else *vals
  bool = !!vals.first
  same,opp = bool ? [:then,:else] : [:else,:then]

  it "should return self if self evaluates to #{!bool}" do
    vals.each do |val|
      val.send(opp).should == val
      val.send(opp,'aye').should == val
      val.send(opp,'aye') {|a,b,c| a}.should == val
      val.send(opp) {|a,b,c| a}.should == val
    end
  end

  it "if self evaluates to #{bool} ##{same} should yield self to a block if one is given, and return that block's value" do
    vals.each do |val|
      val.send(same)   {|v| v.should == val; 'foo'}.should == 'foo'
      val.send(same,1) {|v| v.should == val; 'foo'}.should == 'foo'
    end
  end

  it "should validate arguments if self evaluates to #{bool}" do
    vals.each {|val| lambda{val.send(same)}.should raise_error(ArgumentError)}
    vals.each {|val| lambda{val.send(same){|a,b|}}.should raise_error(ArgumentError)}
    vals.each {|val| lambda{val.send(same){|a,*b|}}.should raise_error(ArgumentError)}
  end
end

describe Object do
  test_then_else('a',true)
  test_then_else(nil,false)

  it "#tap should yield self to a block and return self if block has one argument" do
    [true,false,'a'].each do |o|
      o.tap {|s| s.should == o }.should == o
      o.tap {|s| not s }.should == o
    end
  end
  it "#tap should raise an error if a block has more than one argument" do
    [true,false,'a'].each do |o|
      lambda{ o.tap {|s,a|} }.should raise_error(ArgumentError)
      lambda{ o.tap {|s,*args|} }.should raise_error(ArgumentError)
    end
  end
  it "#tap should instance_eval if a block has return self" do
    [true,false,'a'].each do |o|
      o.tap { self.should == o }.should == o
      o.tap {|*args| self.should == o }.should == o
    end
  end
  it "#tap should send a method to itself" do
    [1, 2, 3, 4, 5].tap { |arr| arr.pop }.should == [1, 2, 3, 4]
    [1, 2, 3, 4, 5].tap(:pop).should == [1, 2, 3, 4]
    [1, 2, 3, 4, 5].tap(:pop) {|arr| arr.pop}.should == [1, 2, 3]
  end
  it "#tap should do nothing if tap is called with no method or block" do
    [1, 2, 3, 4, 5].tap.should == [1, 2, 3, 4, 5]
  end
end
