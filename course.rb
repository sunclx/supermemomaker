require 'rexml/document'
require 'securerandom'
include REXML
require './item.rb'
require './qa.rb'
require './s_text.rb'

class Course
  attr_reader :course

  def initialize(file=nil)
    string = <<EOF
  <?xml version="1.0" encoding="utf-8"?><course xmlns="http://www.supermemo.net/2006/smux"></course>
EOF
    @file = file || 'course.xml'
    File.open(@file, 'w') { |f| f.write(string) } unless File.exist? @file
    @doc = Document.new(File.new(@file))
    @course = @doc.root
    @attributes = {
        'guid' => SecureRandom.uuid,
        'created' => Time.now.to_s[0, 10],
        'modified' => Time.now.to_s[0, 10],
        'language-of-instruction' => 'en',
        'default-taught' => 'en',
        'default-items-per-day' => '30',
        'default-template-id' => '1',
        'type' => 'regular',
        'translators' => 'Eric_Swartz',
        'sorting' => 'default',
        'rights-owner' => 'Eric_Swartz',
        'description' => 'supermemo_maker',
        'box-link' => nil,
        'version' => '1.0.3531'
    }
    @attributes.each_pair { |k, v|
      @course.add_element(k.to_s) unless @course.elements[k.to_s]
      e = @course.elements[k.to_s]
      e.text= v.to_s if e.text == nil or e.text == ''
    }
    self.write_to_file
  end

  def to_s
    @doc.to_s
  end

  def exercise_gen(name='blank')
    id = ((1..99999).to_a - self.id.sort!)[0]
    exercise = @course.add_element('element')
    exercise.add_attributes(id: id, type: 'exercise', name: name)
    exercise
  end

  def write_to_file
    File.open(@file, 'w') { |f| f.write(self.to_s) }
  end

  def id
    exercises = @course.get_elements('//element')
    return exercises.map { |exercise| exercise.attributes['id'].to_i }
  end

  def [](index)
    exercises=@course.get_elements('//element[@type="exercise"]')
    Item.new(self, exercises[index])
  end

  def <<(item)
    @course<< item.item
  end
end
