# :main: README
module MethodChain
  def self_eval &block
    case block.arity
    # ruby bug for -1
    when 0, -1 then instance_eval(&block)
    when 1     then yield(self)
    else            raise ArgumentError, "too many arguments required by block"
    end
  end

  def then arg=nil, &block
    if self
      block_given? ? (self_eval &block) : (arg || (fail \
        ArgumentError, "#then must be called with an argument or a block"))
    else
      self
    end
  end

  def else arg=nil, &block
    if self
      self
    else
      block_given? ? (self_eval &block) : (arg || (fail \
        ArgumentError, "#else must be called with an argument or a bloc"))
    end
  end

  def tap meth=nil, &block
    self.send meth if meth
    self_eval &block if block_given?
    self
  end
end
