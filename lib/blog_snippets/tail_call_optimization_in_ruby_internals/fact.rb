{
  'Fact' => { :tailcall_optimization => false, :trace_instruction => true },
  'TCOFact' => { :tailcall_optimization => true, :trace_instruction => false },
}.each do |class_name, compile_options|
  RubyVM::InstructionSequence.compile_option = compile_options
  code = <<-CODE
    module BlogSnippets
      module #{class_name}
        def self.fact_call(n, accumulator)
          if n == 1
            accumulator
          else
            fact_call(n - 1, n * accumulator)
          end
        end

        def self.factorialize(n)
          fact_call(n, 1)
        end
      end
    end
  CODE
  instruction_sequence = RubyVM::InstructionSequence.new(code)

  puts "#{class_name}:\n#{instruction_sequence.disasm}"
  instruction_sequence.eval
end

# Reset compile options
RubyVM::InstructionSequence.compile_option = { :tailcall_optimization => false, :trace_instruction => true }
