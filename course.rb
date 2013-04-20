require 'rexml/document'
require 'securerandom'
include REXML
require './item.rb'

class Attribute
  def initialize(first, second=nil, parent=nil)
    @normalized = @unnormalized = @element = nil
    if first.kind_of? Attribute
      self.name = first.expanded_name
      @unnormalized = first.value
      if second.kind_of? Element
        @element = second
      else
        @element = first.element
      end
    elsif first.kind_of? String or first.kind_of? Symbol
      @element = parent
      self.name = first
      @normalized = second.to_s
    else
      raise "illegal argument #{first.class.name} to Attribute constructor"
    end
  end
end
class Course
  def initialize(file=nil)
    @file = 'course.xml'
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
    @pre = Element.new('element')
    @ex = @pre.clone
    @pre.add_attributes(id: nil, type: 'pres', name: nil, disabled: 'true')
    @ex.add_attributes(id: nil, type: 'exercise', name: nil)
    @pres = []
    @exercises = []
    @items =[]
  end

  def to_s
    string = <<EOF
  <?xml version="1.0" encoding="utf-8"?><course xmlns="http://www.supermemo.net/2006/smux"></course>
EOF
    @doc = Document.new(string)
    @attributes.each_pair { |k, v| @doc.root.add_element(k.to_s).text= v.to_s }
    @exercises.map { |exercise| exercise.parent||exercise }.uniq.compact.
        each { |e| @doc.root.add_element(e) }
    @doc
  end

  def pres
    @pres #
  end

  def exercise_gen(name='blank')
    @exercises << exercise =@ex.clone
    exercise.add_attributes(id: id_gen, name: name)
    exercise
  end

  def pre_gen(name='blank')
    @pres << exercise =@pre.clone
    exercise.add_attributes(id: id_gen, name: name)
    exercise
  end

  def write_to_file
    File.open(@file, 'w') { |f| f.write(self.to_s) }
  end

  def [](index)
    Item.new(self, @exercises[index])
  end

  def <<(item)
    @items<< item
    @exercises<<item.exercise
  end

  private
  def id_gen
    ((1..99999).to_a- (@exercises+@pres).map { |exercise| exercise.attributes['id'].to_i }.sort!)[0]
  end
end

