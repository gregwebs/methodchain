require File.dirname(__FILE__) + '/methodchain/not-included'

class Object #:nodoc:
  include MethodChain end
