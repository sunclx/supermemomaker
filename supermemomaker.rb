require './course.rb'
course = Course.new
File.foreach('dates.txt') { |line|
  string = SDrapDrop.new.sentence_with_n(line.chomp)
  Item.new(course).set_qa(string.to_s, nil).write_to_file }

course.write_to_file



