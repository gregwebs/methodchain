# :main: README
module MethodChain

private
# public MethodChain methods depend on these private methods
# with the module-import gem you choose which public methods you want to import
# and by default private methods will be included

  # A middleman for passing code as data in 2 different ways
  # * use a Symbol or an Array as the argument list for send
  # * evaluate a Proc-like object with yield_or_eval
  #
  # Symbol | [Method, *MethodArguments] | (to_proc -> Proc)
  def send_as_function arg
    case arg
    when Symbol then __send__ arg
    when Array  then __send__(*arg)
    else             yield_or_eval(&arg)
    end
  end

  # invoke send_as_function multiple times, returns self
  # *Message -> self
  def send_as_functions *args
    args.each {|arg| send_as_function arg}
    self
  end

  # yield self or instance_eval based on the block arity
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

  # method chaining with a +guard+.
  # If no guard block is given then guard against nil and false
  def chain *messages, &guard
    return self if messages.empty? or not(
      (block_given? ? (yield_or_eval(&guard)) : self))

    (send_as_function messages.shift).chain(*messages, &guard)
  end

  # return self if self or any of the +guards+ evaluate to false,
  # otherwise return the evaluation of the block
  def then *guards, &block
    if guards.empty? 
      return self if not self
    else
      guards.each do |cond|
        return self if not (send_as_function cond)
      end
    end

    block_given? ? yield_or_eval(&block) : self
  end

  # return self if self or a guard evaluates to true
  # otherwise return the evaluation of the block
  def else *guards, &block
    if guards.empty? 
      return self if self
    else
      guards.each do |cond|
        return self if send_as_function(cond)
      end
    end

    block_given? ? yield_or_eval(&block) : self
  end

  # with no +guards+, is equivalent to self && yield_or_eval(&block) && self
  # same as: <tt>self.then(*guards, &block) && self</tt>
  def and *guards, &block
    if guards.empty? 
      return self if not self
    else
      guards.each do |cond|
        return self if not send_as_function(cond)
      end
    end

    block_given? ? (yield_or_eval(&block) && self) : self
  end

  # with no +guards+, is equivalent to <tt>self || (yield_or_eval(&block) && self)</tt>
  # same as: <tt>self.else(*guards, &block) && self</tt>
  def or *guards, &block
    if guards.empty? 
      return self if self
    else
      guards.each do |cond|
        return self if send_as_function(cond)
      end
    end

    block_given? ? yield_or_eval(&block) : self
  end
end
