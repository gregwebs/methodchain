# test optional imports

describe "requiring not_tap" do
  it "should not import tap into Object" do
    require File.dirname(__FILE__) + '/../lib/methodchain/then_else'
    MethodChain.should be_kind_of(Module)
    Object.new.should_not respond_to(:tap)
    Object.new.should respond_to(:then)
    Object.new.should respond_to(:else)
  end
end
