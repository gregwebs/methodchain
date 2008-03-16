require File.dirname(__FILE__) + '/../lib/methodchain'

describe "#chain" do
  it "should return self when no arguments or just a block are given" do
    [nil,'a'].each do |var|
      var.chain.should == var
      var.chain {fail}.should == var
    end
  end
  it "should send symbols" do
    [[]].chain(:flatten).should == []
  end
  it "should send procs" do
    [[]].chain(:flatten, lambda{|arr| arr.push('a')}).should == ['a']
    [[]].chain(:flatten, lambda{ push('a') }).should == ['a']
  end
  it "should send an array as a message with arguments" do
    [['a']].chain(:flatten, lambda{|arr| arr.push('b')}, [:join, ' ']).should == 'a b'
  end
  it "should yield self to a block and return self if block has one argument" do
    [true,false,'a'].each do |o|
      o.chain {|s| s.should == o }.should == o
      o.chain {|s| 'foo' }.should == o
    end
  end

  it "should guard the chain against nil and false" do
    nil.chain(:foo,:bar,:baz).should == nil
    false.chain(:foo,:bar,:baz).should == false
    [].chain(:flatten!,:not_defined).should == nil
    [].chain(:flatten!, lambda{|arr| arr.push('a')}).should == nil
    lambda{"foo".chain(:to_s,:not_defined)}.should raise_error(NoMethodError)
  end
  it "should allow custom guards with blocks" do
    nil.chain {nil?}.should == nil
    'a'.chain {nil?}.should == 'a'
    nil.chain(:to_s) {nil?}.should == ''
    'a'.chain(lambda{fail}) {nil?}.should == 'a'

    nil.chain {is_a?(String)}.should == nil
    'a'.chain {is_a?(String)}.should == 'a'
    nil.chain(lambda{fail}) {is_a?(String)}.should == nil
    'a'.chain(:upcase) {is_a?(String)}.should == 'A'
  end
end

describe "#tap" do
  it "should return self when no arguments are given" do
    [true,false,'a'].each do |o|
      o.tap.should == o
    end
  end
  it "should send symbols" do
    [[]].tap(:flatten!).should == []
  end
  it "should send an array as a message with arguments" do
    ['a','b'].tap( [:join, ' '] ).should == ['a','b']
  end
  it "should send procs" do
    [].tap(lambda{|arr| arr.push('a'); 'blah'}).should == ['a']
    [].tap(lambda{ push('a'); 'blah' }).should == ['a']
  end
  it "should yield self to a block and return self if block has one argument" do
    [true,false,'a'].each do |o|
      o.tap {|s| s.should == o }.should == o
      o.tap {|s| not s }.should == o
    end
  end
  it "should raise an error if a block has more than one argument" do
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

describe "#then,#else" do
  test_then_else('a',true)
  test_then_else(nil,false)
end
