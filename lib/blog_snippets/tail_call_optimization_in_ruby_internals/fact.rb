code = <<-CODE
  class Factorial
    def self.fact_helper(n, res)
      n == 1 ? res : fact_helper(n - 1, n * res)
    end

    def self.fact(n)
      fact_helper(n, 1)
    end
  end
CODE

{
  'normal' => { :tailcall_optimization => false, :trace_instruction => false },
  'tail call optimized' => { :tailcall_optimization => true, :trace_instruction => false },
}.each do |identifier, compile_options|
  instruction_sequence = RubyVM::InstructionSequence.new(code, nil, nil, nil, compile_options)
  puts "#{identifier}:\n#{instruction_sequence.disasm}"
end
