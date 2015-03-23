require "bundler/gem_tasks"

task :generate_html, [:source_path] do |tsk, arguments|
  require "blog_snippets/renderers/wordpress_html_renderer"
  require "blog_snippets/markdown_to_html_transformer"

  source_path = arguments[:source_path] || ENV["SOURCE"]
  source_path = File.expand_path(File.join("..", source_path), __FILE__)
  raise "#{source_path} does not exist!" unless File.exist?(source_path)
  raw_source = File.open(source_path, "r") { |f| f.read }
  renderer = BlogSnippets::Renderers::WordpressHTMLRenderer.new
  converter = BlogSnippets::MarkdownToHTMLTransformer.new(:renderer => renderer)
  html = converter.transform(raw_source)
  puts "---- BEGIN COPY ----\n#{html}\n---- END COPY ----"
end
