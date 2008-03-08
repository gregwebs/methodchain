# test optional imports

describe "requiring not_included" do
  it "should not import methods into Object" do
    require File.dirname(__FILE__) + '/../lib/methodchain/not_included'
    Object.new.should_not respond_to(:tap)
    Object.new.should_not respond_to(:then)
    Object.new.should_not respond_to(:else)
    MethodChain.should be_kind_of(Module)
  end
end
