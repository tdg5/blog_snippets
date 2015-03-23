# This script demonstrates that any file loaded after a change to
# RubyVM::InstructionSequence.compile_option will be compiled with the new
# compile options. Rather than do this with two scripts, this script is hacked
# together such that this can be demonstrated with one file that reloads itself
# the first time it is loaded.

# Flag indicating whether this is the first time time this file has been loaded.
$first_load = true if $first_load.nil?

# We can actually turn on tailcall optimization here without affecting how the
# script is loaded the first time because the RubyVM::InstructionSequence object
# that is used to compile the file the first time has already been created and
# as such won't be affected by changing the global compile option.
RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false,
}

# Declare classes to facilitate #instance_eval later
class FirstLoadFactorial; end
class ReloadedFactorial; end

# On the first load, extend FirstLoadFactorial,
# on the second load, extend ReloadedFactorial.
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

# This check avoids calculating the factorial twice; ReloadedFactorial will only
# respond to :fact after the file has been reloaded.
if ReloadedFactorial.respond_to?(:fact)
  begin
    puts "FirstLoadFactorial: #{FirstLoadFactorial.fact(50000).to_s.length}"
  rescue SystemStackError
    puts "FirstLoadFactorial: stack level too deep"
  end

  puts "ReloadedFactorial: #{ReloadedFactorial.fact(50000).to_s.length}"
end

# Reload the file on the first load only.
if $first_load
  $first_load = false
  load __FILE__
end

# $ ruby tail_optimized_reload.rb
#   FirstLoadFactorial: stack level too deep
#   ReloadedFactorial: 213237
