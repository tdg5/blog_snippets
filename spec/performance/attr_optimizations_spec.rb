require 'performance_helper'
require 'blog_snippets/attr_optimizations'

describe BlogSnippets::AttrOptimizations do

  ITERATIONS = 10_000_000

  context 'read/write attribute' do
    it 'is faster to use attr_accessor' do
      minimalist = BlogSnippets::AttrOptimizations::MinimalistAttrs.new
      minimalist_result = speed_test do
        ITERATIONS.times do |i|
          minimalist.accessor = i
          minimalist.accessor
        end
      end

      puts "Minimalist attr_accessor time: #{minimalist_result}"

      excessive = BlogSnippets::AttrOptimizations::ExcessiveAttrs.new
      excessive_result = speed_test do
        ITERATIONS.times do |i|
          excessive.accessor = i
          excessive.accessor
        end
      end

      puts "Excessive attr_accessor time: #{excessive_result}"
    end
  end

  context 'read-only attribute' do
    it 'is faster to use attr_reader' do
      minimalist = BlogSnippets::AttrOptimizations::MinimalistAttrs.new
      minimalist.instance_variable_set(:@reader, 1)
      minimalist_result = speed_test do
        ITERATIONS.times do |i|
          minimalist.reader
        end
      end

      puts "Minimalist attr_reader time: #{minimalist_result}"

      excessive = BlogSnippets::AttrOptimizations::ExcessiveAttrs.new
      excessive.instance_variable_set(:@reader, 1)
      excessive_result = speed_test do
        ITERATIONS.times do |i|
          excessive.reader
        end
      end

      puts "Excessive attr_reader time: #{excessive_result}"
    end
  end

  context 'write-only attribute' do
    it 'is faster to use attr_writer' do
      minimalist = BlogSnippets::AttrOptimizations::MinimalistAttrs.new
      minimalist_result = speed_test do
        ITERATIONS.times do |i|
          minimalist.writer = i
          minimalist.writer = nil
        end
      end

      puts "Minimalist attr_writer time: #{minimalist_result}"

      excessive = BlogSnippets::AttrOptimizations::ExcessiveAttrs.new
      excessive_result = speed_test do
        ITERATIONS.times do |i|
          excessive.writer = i
          excessive.writer = nil
        end
      end

      puts "Excessive attr_writer time: #{excessive_result}"
    end
  end
end
