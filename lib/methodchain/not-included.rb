# :main: README
module MethodChain

private

  #   arg = Message | Code
  #   Message = Symbol | [Symbol, *arguments]
  #   Code.to_proc = Proc
  def send_as_function arg
    case arg
    when Symbol then __send__ arg
    when Array  then __send__(*arg)
    else             yield_or_eval(&arg)
    end
  end

  # send_as_function with multiple args, returns self
  def send_as_functions *args
    args.each {|arg| send_as_function arg}
    self
  end

  # yield or instance_eval based on the block arity
  def yield_or_eval &block
    case block.arity
    # ruby bug for -1
    when 0, -1 then instance_eval(&block)
    when 1     then yield(self)
    else            raise ArgumentError, "too many arguments required by block"
    end
  end

public

  # send messages, evaluate blocks, but always return self
  def tap *messages, &block
    send_as_functions *messages unless messages.empty?
    yield_or_eval(&block) if block_given?
    self
  end

  # method chaining with a guard.
  # If no guard block is given then guard against nil and false
  def chain *messages, &guard
    return self if messages.empty? or not(
      (block_given? ? (yield_or_eval(&guard)) : self))

    (send_as_function (messages.shift)).chain(*messages, &guard)
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
