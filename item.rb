require './course.rb'
class Item
  attr_reader :item

  def initialize(course, attributes={})

    @name='blank0'
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
    @q='ooj'
    @a='jjjj'
    @pres = self
    self.write_to_file
  end

  def self.build(course, attributes={})
    item = self.new(course, attributes)
    yield item if block_given?
    item
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
    #@doc.root.elements['question'].text = @q.to_s
    #@doc.root.elements['answer'].text = @a.to_s
    @doc.to_s #.gsub('&l;', '<').gsub('&gt;', '>')
  end

=begin
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
=end
  def write_to_file
    File.open(@file, 'w') { |f| f.write(self.to_s) }
  end
end