# :main: README
module MethodChain

  # send a method, evaluate a block, but always return self
  def tap meth=nil, &block
    __send__ meth if meth
    yield_or_eval(&block) if block_given?
    self
  end

  # method chaining with a guard.
  # If no guard block is given then guard against nil and false
  # *methods = [method] where
  #   method = Message | Code
  #   Message = Symbol | [Symbol, *arguments]
  #   Code.to_proc = Proc
  def chain *methods, &guard
    return self if methods.empty? or not(
      (block_given? ? (yield_or_eval(&guard)) : self))

    case(meth = methods.shift)
    when Symbol then __send__ meth
    when Array  then __send__(*meth)
    else             yield_or_eval(&meth)
    end.chain(*methods, &guard)
  end

  # yield or eval based on the block arity
  def yield_or_eval &block
    case block.arity
    # ruby bug for -1
    when 0, -1 then instance_eval(&block)
    when 1     then yield(self)
    else            raise ArgumentError, "too many arguments required by block"
    end
  end

  # return self if self evaluates to false, otherwise
  # evaluate the block or return the default argument
  def then default=nil, &block
    if self
      block_given? ? (yield_or_eval(&block)) : (default || (fail \
        ArgumentError, "#then must be called with an argument or a block"))
    else
      self
    end
  end

  # the inverse of then
  def else arg=nil, &block
    if self
      self
    else
      block_given? ? (yield_or_eval(&block)) : (arg || (fail \
        ArgumentError, "#else must be called with an argument or a bloc"))
    end
  end
end
