{
  "Fib" => { :tailcall_optimization => false, :trace_instruction => false },
  "TCOFib" => { :tailcall_optimization => true, :trace_instruction => false },
}.each do |class_name, compile_options|
  RubyVM::InstructionSequence.compile_option = compile_options
    code = <<-CODE
    module BlogSnippets
      module #{class_name}
        def self.acc(i, n, result)
          if i == -1
            result
          else
            acc(i - 1, n + result, n)
          end
        end

        def self.fib(i)
          acc(i, 1, 0)
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
