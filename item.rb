require './course.rb'
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