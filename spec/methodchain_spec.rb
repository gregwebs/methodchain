require File.dirname(__FILE__) + '/../lib/methodchain'

#TODO
# test message sending with #and and #or using shared_examples_for

class Object; def return_nil() nil end end

shared_examples_for "self-returning method" do
  it 'should returns self when no arguments are given' do
    @objects.each { |obj| obj.send(@meth).should == obj }
  end

  it 'should returns self when a block with no arguments is given' do
    @objects.each { |obj| obj.send(@meth) {}.should == obj }
  end

  it 'should return self when a block with one argument is given' do
    @objects.each { |obj| obj.send(@meth) {|_|}.should == obj }
  end
end


describe 'any object' do
  before do
    @trues = [true,'a']
    @falses = [false,nil]
    @objects = @trues + @falses
  end

  describe "#chain" do
    before { @meth = :chain }
    it_should_behave_like "self-returning method"

    it "should not evaluate a block when just a block is given" do
      @objects.each { |obj| obj.chain {fail}.should == obj }
    end

    it "should send symbols" do
      @trues.should  each {|obj| obj.chain(:class).should == obj.class }
      @falses.should each {|obj| obj.chain(:class).should == obj }
    end

    it "should send procs" do
      @trues.should  each {|obj| obj.chain(lambda{|o| o.class}).should == obj.class }
      @falses.should  each {|obj| obj.chain(lambda{|o| o.class}).should == obj }
    end

    it "should send an array as a message with arguments" do
      @trues.should  each {|obj| obj.chain([:class]).should == obj.class }
      @falses.should each {|obj| obj.chain([:class]).should == obj }
    end

    it "should yield self to a block and return self if block has one argument" do
      @objects.should( each do |o|
        o.chain {|s| s.should == o }.should == o
        o.chain {|s| 'foo' }.should == o
      end )
    end

    it "should guard the chain against nil and false" do
      @falses.should each {|f| f.chain(:meth1, :meth2).should == f }
      @trues.should  each {|t| t.chain(:return_nil, :meth1, :meth2).should == nil }
      @trues.should  each {|t| lambda{t.chain(:not_defined)}.should raise_error(NoMethodError) }
    end

    it "should allow custom guards with blocks" do
      (@trues + [false]).should  each {|o| o.chain(lambda{fail}) {nil?}.should == o}
      nil.chain(:to_s) {nil?}.should == ''
    end
  end

  describe "#tap" do
    before { @meth = :tap }
    it_should_behave_like "self-returning method"

    it "should yield self to a block and return self if block has one argument" do
      @objects.should( each do |o|
        o.tap {|s| s.should == o }.should == o
        o.tap {|s| not s }.should == o
      end )
    end

    it "#tap should instance_eval if a block has return self" do
      @objects.should( each do |o|
        o.tap { self.should == o }.should == o
        o.tap {|*args| self.should == o }.should == o
      end )
    end

    it "should raise an error if a block has more than one argument" do
      @objects.should( each do |o|
        lambda{ o.tap {|s,a|} }.should raise_error(ArgumentError)
        lambda{ o.tap {|s,*args|} }.should raise_error(ArgumentError)
      end )
    end
  end


  describe "Object#and" do
    it "should return self or a value that evaluates to false" do
      @trues.each do |val|
        val.and {false}.should == false
        val.and {'a'}.should == val
      end
      @falses.should( each do |val|
        val.and {false}.should == val
        val.and {nil}.should == val
        val.and {true}.should == val
      end )
    end
  end


  describe "Object#or" do
    it "should return self or a value that evaluates to false" do
      @trues.should( each do |val|
        val.or {false}.should == val
        val.or {'a'}.should == val
      end )
      @falses.should( each do |val|
        val.or {false}.should == false
        val.or {nil}.should == nil
        val.or {true}.should == true
      end )
    end
  end
end

describe "#tap" do
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
  it "#tap should send a method to itself" do
    [1, 2, 3, 4, 5].tap { |arr| arr.pop }.should == [1, 2, 3, 4]
    [1, 2, 3, 4, 5].tap(:pop).should == [1, 2, 3, 4]
    [1, 2, 3, 4, 5].tap(:pop) {|arr| arr.pop}.should == [1, 2, 3]
  end
  it "#tap should do nothing if tap is called with no method or block" do
    [1, 2, 3, 4, 5].tap.should == [1, 2, 3, 4, 5]
  end
end


shared_examples_for 'then/else' do
  it "should return self if no conditions are given and self evaluates to #{!@bool}" do
    @vals.should( each do |val|
      val.send(@opp).should == val
      val.send(@opp) {|a,b,c| a}.should == val
    end )
  end

  it "should return self if no block is given" do
    @vals.should( each do |val|
      val.send(@same, proc{self}).should == val
      val.send(@same, proc{not self}).should == val
      val.send(@opp, proc{self}).should == val
      val.send(@opp, proc{not self}).should == val

      lambda{val.send(@same, proc{fail})}.should raise_error
      lambda{val.send(@opp, proc{fail})}.should raise_error
    end )
  end

  it "if self evaluates to #{@bool} ##{@same} should yield self to a block if one is given, and return that block's value" do
    @vals.should( each do |val|
      val.send(@same)   {|v| v.should == val; 'foo'}.should == 'foo'
    end )
  end

  it "if self evaluates to #{!@bool} ##{@opp} should yield self to a block if one is given, and return that block's value" do
    @vals.should( each do |val|
      val.send(@opp) {|v| v.should == val; 'foo'}.should == val
    end )
  end

  it "should test conditions" do
    @vals.should( each do |val|
      val.send(@same, proc{self}) {"test"}.should == "test"
      val.send(@same, proc{not self}) {fail}.should == val

      val.send(@opp, proc{self}) {fail}.should == val
      val.send(@opp, proc{not self}) {"test"}.should == "test"
    end )
  end
end


describe 'true values' do
  it_should_behave_like 'then/else'

  before do
    @vals = ['a',true]
    @bool = !!@vals.first
    @same, @opp = @bool ? [:then,:else] : [:else,:then]
  end
end

describe 'false values' do
  it_should_behave_like 'then/else'

  before do
    @vals = [nil,false]
    @bool = !!@vals.first
    @same, @opp = @bool ? [:then,:else] : [:else,:then]
  end
end
