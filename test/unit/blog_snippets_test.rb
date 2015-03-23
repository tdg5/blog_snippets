require "test_helper"

class BlogSnippetsTest < BlogSnippets::TestCase
  Subject = BlogSnippets

  subject { Subject }

  context Subject.name do
    should "be defined" do
      assert defined?(subject), "Expected #{subject.name} to be defined!"
    end
  end
end
