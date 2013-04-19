require './course.rb'
course = Course.new
File.foreach('dates.txt') { |line|
  string = SText.new(line.chomp)
  Item.build(course) { |item|
    item.qa = QA.new(string, string)
    item.write_to_file
  } }

course.write_to_file



