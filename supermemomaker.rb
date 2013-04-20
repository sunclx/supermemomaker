require './course.rb'
course = Course.new
File.foreach('dates.txt') { |line|
  block = SDrapDrop.new.sentence_with_n(line.chomp)
  Item.new(course).add_to_question(block).write_to_file }

course.write_to_file



