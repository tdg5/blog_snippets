Pry.commands.command("tag-session", "Append a tag to the session name.") do |tag_name|
  $0 += "[#{tag_name}]"
end
