require 'rexml/document'
require 'securerandom'
include REXML

class Course
  attr_accessor :course, :guid, :created, :modified, :language_of_instruction, :default_taught, :default_items_per_day,
                :default_template_id, :type, :translators, :sorting, :author, :rights_owner, :description, :box_link,
                :version

  def initialize(document=nil)
    string = <<EOF
  <?xml version="1.0" encoding="utf-8"?><course xmlns="http://www.supermemo.net/2006/smux"></course>
EOF
    document ||= string
    @doc = Document.new(document)
    @course = @doc.root
    @course << @guid = Element.new('guid')
    @guid.text= SecureRandom.uuid
    @course << @created = Element.new('created')
    @created.text = Time.now.to_s[0, 10]
    @course << @modified = Element.new('modified')
    @modified.text = Time.now.to_s[0, 10]
    @course << @language_of_instruction = Element.new('language-of-instruction')
    @language_of_instruction.text = 'en'
    @course << @default_taught = Element.new('default-taught')
    @default_taught.text ='en'
    @course << @default_items_per_day = Element.new('default-items-per-day')
    @default_items_per_day.text = '30'
    @course << @default_template_id = Element.new('default-template-id')
    @default_template_id.text = '1'
    @course << @type = Element.new('type')
    @type.text = 'regular'
    @course << @translators = Element.new('translators')
    @translators.text = 'Eric_Swartz'
    @course << @sorting = Element.new('sorting')
    @sorting.text = 'default'
    @course << @rights_owner = Element.new('rights-owner')
    @rights_owner.text = 'Eric_Swartz'
    @course << @description = Element.new('description')
    @description.text = 'supermemo_maker'
    @course << @box_link = Element.new('box-link')
    @box_link.text= nil
    @course << @version = Element.new('version')
    @version.text = '1.0.3531'
    @items = Items.new(@course)
  end

  def to_s
    @course.to_s
  end

  def id_gen
    @id ||= 0
    @id += 1
  end

  def [](par)
    @items[par]
  end

  def <<(item)
    @items << item
  end

  def makefile
    File.open('course.xml', 'w') { |f| f.write(@doc) }
    (1..10).each { |item|
      File.open('item'+('%05d'%item)+'.xml', 'w') { |f|
        f.write(item.to_s)
      } }
  end
end

class Items
  def initialize(course)
    @course = course
    @items = @course.get_elements('//element[@type="exercise"]')
  end

  def [](index=nil, id=nil)
    @items.each { |e| return e if e.attributes['id']=id.to_s } if id.kind_of? Numeric
    case index.class
      when Numeric;
        return @items[index]
      when String, Symbol;
        @items.each { |e| return e if e.attributes['name']=index.to_s }
    end
  end

  def <<(item)
    @course<< item.item
  end

  def each
    @items.each { |items| yield items }
  end
end

class Item
  def initialize(qa =nil, course=nil, document=nil)
    string = <<EOF
   <?xml version="1.0" encoding="utf-8"?><item xmlns="http://www.supermemo.net/2006/smux"></item>
EOF
    document ||= string
    @doc = Document.new(document)
    @item=@doc.root
    @course = course || Course.new
    @id = @course.id_gen
    @item<<@lesson_title = Element.new('lesson-title')
    @lesson_title.text = lesson_title
    @item<<@chapter_title = Element.new('chapter-title')
    @chapter_title.text = chapter_title
    @item<<@question_title = Element.new('question-title')
    @question_title.text = question_title
    @item<<@question = Element.new('question')
    @item<<@answer = Element.new('answer')
    @item<<@modified = Element.new('modified')
    @modified.text = Time.now.to_s[0, 10]
    @item<<@template_id = Element.new('template-id')
    @template_id.text = '1'
    @course << self
    @pres = nil
  end

  def to_s
    @doc.to_s
  end

  attr_reader :item, :lesson_title, :chapter_title, :question_title, :modified, :template_id, :course, :id
  attr_accessor :question, :answer
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
File.foreach('dates.txt') { |line| Item.new(makeQA(line), course) }
course.makefile

p '%05d'% 123

