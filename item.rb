require './course.rb'

class Item
  attr_reader :question, :answer

  def initialize(course, attributes={})
    @name='blank'
    @exercise=course.exercise_gen(@name)
    @file = 'item'+'%05d'%self.id+'.xml'
    @attributes = {
        'lesson-title' => 'lesson_title',
        'chapter-title' => 'chapter_title',
        'question-title' => 'question_title',
        'question' => nil,
        'answer' => nil,
        'modified' => Time.now.to_s[0, 10],
        'template-id' => '1'
    }
    @attributes.merge! attributes
    @question=nil.to_s
    @answer=nil.to_s
    @pres = self
  end

  def id
    @exercise.attributes['id'].to_i
  end

  def to_s
    string = <<EOF
<?xml version="1.0" encoding="utf-8"?><item xmlns="http://www.supermemo.net/2006/smux"></item>
EOF
    @doc = Document.new(string)
    @attributes.each_pair { |k, v|
      e=@doc.root.add_element(k.to_s)
      e.text = v.to_s }
    @doc.root.elements['question'].text = @question.to_s
    @doc.root.elements['answer'].text = @answer.to_s
    @doc.to_s.gsub('&lt;', '<').gsub('&gt;', '>')
  end

  def add_to_question(block)
    @question +=block.to_s
    self
  end

  def add_to_answer(block)
    @answer +=block.to_s
    self
  end

  def set_qa(q=nil, a=nil)
    @question=q ? q.to_s : @question
    @answer=a ? q.to_s : @answer
    self
  end

  def write_to_file
    File.open(@file, 'w') { |f| f.write(self.to_s) }
  end
end
