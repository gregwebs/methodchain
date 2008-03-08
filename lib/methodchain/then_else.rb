require File.dirname(__FILE__) + '/methodchain'

module MethodChain # :nodoc:
  include ThenElse end
class Object # :nodoc:
  include MethodChain end
