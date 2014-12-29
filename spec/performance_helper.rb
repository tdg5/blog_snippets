require 'spec_helper'
require 'benchmark'

module PerformanceHelper

  def speed_test(&block)
    raise "#{__method__} requires a block." unless block_given?
    # GC.disable returns false if the GC was disabled and true if the GC was
    # already disabled.
    gc_was_enabled = !GC.disable
    time = Benchmark.realtime(&block)
    GC.enable if gc_was_enabled
    time
  end

end

RSpec.configure { |config| config.include(PerformanceHelper) }
