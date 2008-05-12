class MatchEach
  def initialize &block
    @block = block
  end

  def matches?(target)
    target.each do |obj|
      begin  @block.call(obj)
      rescue Spec::Expectations::ExpectationNotMetError => e
        @error_msg = e.to_s
        @failure_object = obj
        return false
      end
    end
    true
  end

  def failure_message
    if @error_msg =~ /expected not/ then '    ' else '' end <<
      " element: #{@failure_object.inspect}\n#{@error_msg}"
  end

  # no need for should_not, so no negative_failure_messages
end

def each &block
  MatchEach.new &block
end
