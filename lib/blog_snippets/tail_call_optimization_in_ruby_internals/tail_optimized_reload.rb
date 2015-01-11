# Flag indicating whether this is the first time time this file has been loaded
$first_load = true if $first_load.nil?

# Declare classes to facilitate #instance_eval later
class FirstLoadFactorial; end
class ReloadedFactorial; end

# On the first load, extend FirstLoadFactorial
# On the second load, extend ReloadedFactorial
klass = $first_load ? FirstLoadFactorial : ReloadedFactorial

# Tail recursive factorial adapted from
# https://github.com/ruby/ruby/blob/fcf6fa8781fe236a9761ad5d75fa1b87f1afeea2/test/ruby/test_optimization.rb#L213
klass.instance_eval do
  def self.fact_helper(n, res)
    n == 1 ? res : fact_helper(n - 1, n * res)
  end

  def self.fact(n)
    fact_helper(n, 1)
  end
end

# Turn on tailcall optimization
RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false,
}

# This check avoids calculating the factorial twice; ReloadedFactorial will only
# respond to :fact after the file has been reloaded.
if ReloadedFactorial.respond_to?(:fact)
  begin
    puts "FirstLoadFactorial: #{FirstLoadFactorial.fact(50000).to_s.length}"
  rescue SystemStackError
    puts 'FirstLoadFactorial: stack level too deep'
  end

  puts "ReloadedFactorial: #{ReloadedFactorial.fact(50000).to_s.length}"
end

# Reload the file on the first load only
if $first_load
  $first_load = false
  load __FILE__
end

# $ ruby tail_optimized_reload.rb
#   FirstLoadFactorial: stack level too deep
#   ReloadedFactorial: 213237
