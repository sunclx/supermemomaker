require 'rexml/document'
require 'securerandom'
include REXML
require './item.rb'
require './qa.rb'
require './s_text.rb'

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
    self.write_to_file
  end

  def to_s
    string = <<EOF
  <?xml version="1.0" encoding="utf-8"?><course xmlns="http://www.supermemo.net/2006/smux"></course>
EOF
    @doc = Document.new(string)
    @attributes.each_pair { |k, v| @doc.root.add_element(k.to_s).text= v.to_s }
    @exercises.each { |exercise| @doc.root.add_element(exercise) }
    @doc
  end

  def exercise_gen(name='blank')
    id = ((1..99999).to_a - self.ids.sort!)[0]
    @exercises << exercise =@ex.clone
    exercise.add_attributes(id: id, name: name)
    exercise
  end

  def write_to_file
    File.open(@file, 'w') { |f| f.write(self.to_s) }
  end

  def ids
    return @exercises.map { |exercise| exercise.attributes['id'].to_i }
  end

  def [](index)
    Item.new(self, @exercises[index])
  end

  def <<(item)
    @items<< item
    @exercises<<item.exercise
  end
end

