require 'rexml/document'
require 'securerandom'
include REXML

class Course < Document
  attr_accessor :course,:guid,:created,:modified,:language_of_instruction,:default_taught,:default_items_per_day,
                :default_template_id,:type,:translators,:sorting,:author,:rights_owner,:description,:box_link,
                :version

  def initialize(document=nil)
    super('<?xml version="1.0" encoding="utf-8"?><course xmlns="http://www.supermemo.net/2006/smux"></course>')
    @course =self.root
    @course << @guid = Element.new('guid')
    @guid = @guid.text= SecureRandom.uuid
    @course << @created = Element.new('created')
    @created = @created.text = Time.now.to_s[0,10]
    @course << @modified = Element.new('modified')
    @modified = @modified.text = Time.now.to_s[0,10]
    @course << @language_of_instruction = Element.new('language-of-instruction')
    @language_of_instruction = @language_of_instruction.text = 'en'
    @course << @default_taught = Element.new('default-taught')
    @default_taught = @default_taught.text ='en'
    @course << @default_items_per_day = Element.new('default-items-per-day')
    @default_items_per_day =@default_items_per_day.text = '30'
    @course << @default_template_id = Element.new('default-template-id')
    @default_template_id = @default_template_id.text = '1'
    @course << @type = Element.new('type')
    @type = @type.text = 'regular'
    @course << @translators = Element.new('translators')
    @translators = @translators.text = 'Eric_Swartz'
    @course << @sorting = Element.new('sorting')
    @sorting = @sorting.text = 'default'
    @course << @rights_owner = Element.new('rights-owner')
    @rights_owner = @rights_owner.text = 'Eric_Swartz'
    @course << @description = Element.new('description')
    @description = @description.text = 'supermemo_maker'
    @course << @box_link = Element.new('box-link')
    @box_link = @box_link.text= nil
    @course << @version = Element.new('version')
    @version = @version.text = '1.0.3531'
  end

  def exercises
     self.get_elements('//element[@type="exercise"]')
  end

  def pres
    self.get_elements('//element[@type="pres"]')
  end
  def add_exercise(id='1',name='blank',subtype=nil)
    tmp = Element.new('element')
    tmp.add_attributes(id:id.to_s,name:name,type:'exercise',subtype:subtype)
    @course<<tmp
  end

  def add_pres(element, name='blank', disabled='true',subtype=nil)
    pa = get_elements("//element[@type='pres']")[0]
    if pa
      pa.add_element(element)
    else
      tmp =  element.clone
      element.add_attributes(id:'99999',name:name,type:'pres',disabled:disabled,subtype:subtype)
      element<<tmp
    end
  end


end


class Item < Document
  def initialize(question = nil,lesson_title=nil,chapter_title=nil,question_title=nil)
    super('<?xml version="1.0" encoding="utf-8"?><item xmlns="http://www.supermemo.net/2006/smux"></item>')
    @parent =nil
    @item = self.root
    @item<<@lesson_title = Element.new('lesson-title')
    @lesson_title= @lesson_title.text = lesson_title
    @item<<@chapter_title = Element.new('chapter-title')
    @chapter_title = @chapter_title.text = chapter_title
    @item<<@question_title = Element.new('question-title')
    @question_title = @question_title.text = question_title
    @item<<@question = Element.new('question')
    @item<<@answer = Element.new('answer')
    @item<<@modified = Element.new('modified')
    @modified = @modified.text = Time.now.to_s[0,10]
    @item<<@template_id = Element.new('template-id')
    @template_id = @template_id.text = '1'
  end

  attr_reader :lesson_title,:chapter_title,:question_title,:modified,:template_id
  attr_accessor :question,:answer

  def drap_drop(sentence,n,orientation='horizontal',dropsign='10')
    dd = Element.new('drap-drop')
    dd.add_attributes(orentation:orientation,dropsign:dropsign)
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

item = Item.new
item.question<<item.drap_drop('I am a student.',1)
p item.question

course = Course.new
1.upto(6){|i| course.add_exercise('%05d'%i)}
p course.exercises
p '%05d'% 123

