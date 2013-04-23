require './course.rb'

class Block
  def initialize(attributes={})
    @element =nil
    @attributes ||={}
    @attributes.merge! attributes
  end

  def to_s
    return @string.to_s if @string
    @string = Element.new(@element)
    @attributes.each_pair { |k, v| @string.add_attribute(k.to_s, v) }
    self.sub_elements.each { |element| @string << element }
    self.freeze
    @string.to_s
  end

  def sub_elements

  end

end
class SText < Block
  def initialize(text)
    @string = text
  end
end
class SDrapDrop < Block
  def initialize(attributes={})
    @attributes = {
        orientation: nil,
        dropsign: '10'
    }
    super
    @element= 'drap-drop'
    @question = Element.new('drop-text')
    @opt = Element.new('option')
    @options = []
  end

  def sub_elements
    [@question,] + @options
  end

  def sentence_with_n(sentence, n=3)
    words = sentence.split(/\s/)
    n = words.size if words.size < 3
    indexes = []
    loop {
      indexes << SecureRandom.random_number(words.size)
      indexes.uniq!
      break if indexes.size >= n
    }
    indexes.sort!
    indexes.each_with_index { |v, i|
      a = @opt.clone
      a.add_text(words[v])
      @options << a
      words[v] = "[#{i}]"
    }
    @question.text= words.join(' ')
    self
  end

  def sentence_with_percent(sentence, percent = 0.2)
    n = (sentence.split(/\s/).size * percent).to_i
    self.sentence_with_n(sentence, n)
  end
end

class SOrderList < Block
  def initialize
    @attributes = {orientation: 'horizontal'}
    @element = 'ordering-list'
    @opt = Element.new('option')
    @options = []
  end

  def build_by_sentence(sentence)
    words = sentence.split(/\s/)
    self.build_by_options
  end

  def build_by_options(options=[])
    def a_option(text)
      option = @opt.clone
      option.text = text
      option
    end

    options.each { |option| @options << a_option(option) }
    self
  end
end

class SRadio<Block
  def initialize(attributes={})
    @attributes = {orientation: 'horizontal'}
    super
    @element= Element.new('radio')
    @opt = Element.new('option')
    @options = []
  end

  def sub_elements
    @options
  end

end
class SDropList
  def initialize(attributes={})
    @attributes = {orientation: 'horizontal'}
    @opt = Element.new('option')
    @option =[]
  end
end
class SSpellPad
  def initialize(attributes)
    @attributes = {
        correct: 'give',
        matchcase: 'true'
    }
    @spellpad = Element.new('spellpad')
  end
end
class STip
  def initialize
    @element = Element.new('text')
    @sentence = Element.new('sentence')
    @translation = Element.new('translation')
  end
end
