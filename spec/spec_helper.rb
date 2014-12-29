RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # i_dont_suck_and_my_tests_are_not_order_dependent!
  config.order = :random

  # Experimental. May be noisy depending on included gems/libraries
  config.warnings = true
end
