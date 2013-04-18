require 'rexml/document'
require 'securerandom'
include REXML

class Course
  attr_accessor :course

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
  end

  def to_s
    @doc.to_s
  end

  def exercise_gen(name='blank')
    id = ((1..99999).to_a - self.id.sort!)[0]
    exercise = @course.add_element('element')
    exercise.add_attributes(id: id, type: 'exercise', name: name)
    File.open(@file, 'w') { |f| f.write(self.to_s) }
    exercise
  end

  def id
    exercises = @course.get_elements('//element')
    return exercises.map { |exercise| exercise.attributes['id'].to_i }
  end

  def [](index)
    @course.get_elements('//element[@type="exercise"]')[index]
  end

  def <<(item)
    @course<< item
  end

  def makefile
    File.open('course.xml', 'w') { |f| f.write(@doc) }
    (1..10).each { |item|
      File.open('item'+('%05d'%item)+'.xml', 'w') { |f|
        f.write(item.to_s)
      } }
  end
end

class Item
  def initialize(course, file=nil)
    string = <<EOF
<?xml version="1.0" encoding="utf-8"?><item xmlns="http://www.supermemo.net/2006/smux"></item>
EOF
    @name='blank0'
    @exercise=course.exercise_gen(@name)
    @file = 'item'+'%05d'%self.id+'.xml'
    File.open(@file, 'w') { |f| f.write(string) } unless File.exist? @file
    @doc = Document.new(File.new(@file))
    @item=@doc.root
    @attributes = {
        'lesson-title' => 'lesson_title',
        'chapter-title' => 'chapter_title',
        'question-title' => 'question_title',
        'modified' => Time.now.to_s[0, 10],
        'template-id' => '1'
    }

    @pres = nil
  end

  def id
    @exercise.attributes['id'].to_i
  end

  def to_s
    @doc.to_s
  end
end
class Pres < Item
  "[id:id.to_s,name:name,type:'exercise',subtype:subtype]
    [element, name='blank', disabled='true',subtype=nil]
    [id:'99999',name:name,type:'pres',disabled:disabled,subtype:subtype]"
end
class QA

end
class Block

end
class Drap_drop < Block
  def drap_drop(sentence, n, orientation='horizontal', dropsign='10')
    dd = Element.new('drap-drop')
    dd.add_attributes(orentation: orientation, dropsign: dropsign)
    words = sentence.split(/\s/)
    i=SecureRandom.random_number(words.size)
    options =[words[i]]
    words[i]='[0]'
    dd<<drop_text = Element.new('drop-text')
    drop_text.text = words.join(' ')
    dd<<option = Element.new('option')
    option.text = options[0]
    dd
  end
end

def makeQA(lines)
  nil
end

course = Course.new
Item.new(course)
Item.new(course)
print course.id


p '%05d'% 123

