require File.dirname(__FILE__) + '/methodchain/not_included'

class Object # :nodoc:
  include MethodChain end
