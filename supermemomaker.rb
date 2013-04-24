require './course.rb'
require './block.rb'
course = Course.new
=begin
File.foreach('dates.txt') { |line|
  block = SDrapDrop.new.sentence_with_n(line.chomp)
  puts block.to_s
  Item.new(course).add_to_question(block).write_to_file
}
course.write_to_file
=end
block = SDrapDrop.new.sentence_with_n('I saw that a tiger sat under the tree.')
puts block
puts block
puts Element.new(nil.to_s)





