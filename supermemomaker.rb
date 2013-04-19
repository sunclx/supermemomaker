require 'rexml/document'
require 'securerandom'
include REXML

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

class Item
  attr_reader :item

  def initialize(course, exercise =nil, file=nil)
    string = <<EOF
<?xml version="1.0" encoding="utf-8"?><item xmlns="http://www.supermemo.net/2006/smux"></item>
EOF
    @name='blank0'
    if exercise ==nil
      @exercise=course.exercise_gen(@name)
    else
      @exercise = exercise
    end
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
    @attributes.each_pair { |k, v|
      @item.add_element(k.to_s) unless @item.elements[k.to_s]
      e = @item.elements[k.to_s]
      e.text= v.to_s if e.text == nil or e.text == ''
    }
    @item.add_element('question')
    @item.add_element('answer')
    @pres = nil
    self.write_to_file
  end

  def self.build(course, exercise=nil, file=nil)
    item = self.new(course, exercise, file)
    yield item if block_given?
    item
  end

  def id
    @exercise.attributes['id'].to_i
  end

  def to_s
    @doc.to_s
  end

  def qa
    QA.new(@item.elements['question'], @item.elements['answer'])
  end

  def qa=(qa)
    self << qa
  end

  def <<(qa)
    @item.delete_element(@item.elements['//question'])
    @item.delete_element(@item.elements['//answer'])
    @item<<qa.element[0]
    @item<<qa.element[1]
  end

  def write_to_file
    File.open(@file, 'w') { |f| f.write(self.to_s) }
  end
end

class QA
  attr_reader :element

  def initialize(question=nil, answer=nil)
    @element =[Element.new('question'), Element.new('answer')]
    @q=@element[0].text = question.to_s
    @a=@element[1].text = answer.to_s

    def @q.<<(string)
      @q.text += string
    end

    def @a.<<(string)
      @a.text+=string
    end
  end

  def q
    @q.text
  end

  def q=(string)
    @q.text = string
  end

  def a
    @a.text
  end

  def a=(string)
    @a.text = string
  end
end

class Block
  def initialize(text=nil)
    @string = text
  end

  def to_s
    @string.gsub!('<', '&lt;')
    @string.gsub!('>', '&gt;')
    @string.to_s
  end
end

class SMtext < Block
  def initialize(text)
    @string = text
  end
end
=begin class Drap_drop < Block
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
=end


course = Course.new
File.foreach('dates.txt') { |line|
  string = SMtext.new(line.chomp)
  Item.build(course) { |item|
    item.qa = QA.new(string, string)
    item.write_to_file
  } }

course.write_to_file



