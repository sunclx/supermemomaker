require './course.rb'

class Block <Object
  def initialize(attributes={})
    @element =nil
    @attributes ||={}
    @attributes.merge! attributes
    @opt = Element.new('option')
  end

  def to_s
    return @string.to_s if @string
    @string = Element.new(@element)
    @attributes.each_pair { |k, v| @string.add_attribute(k.to_s, v) }
    sub_elements.each { |element| @string << element }
    self.freeze
    @string.to_s
  end

  private
  def sub_elements

  end

end
class SText < Block
  def initialize(text='')
    @string = text
  end

  def build_by_text(text)
    @string =text
    self.freeze
    self
  end

  undef :sub_elements
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
    @options = []
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

  private
  def sub_elements
    [@question,] + @options
  end
end

class SOrderList < Block
  def initialize
    @attributes = {orientation: 'horizontal'}
    @element = 'ordering-list'
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

  private
  def sub_elements
    @options
  end
end

class SRadio<Block
  def initialize(attributes={})
    @attributes = {orientation: 'horizontal'}
    super
    @element= Element.new('radio')
    @options = []
  end

  private
  def sub_elements
    @options
  end

end
class SDropList <Block
  def initialize(attributes={})
    @attributes = {orientation: 'horizontal'}
    @element =
        @option =[]
  end
end
class SSpellPad
  def initialize(attributes)
    @attributes = {
        correct: 'give',
        matchcase: 'true'
    }
    @element = Element.new('spellpad')
  end

  def build_by_text(text)
    @element.text = text
    @string= @element.to_s
    self.freeze
    self
  end

end
class STip
  def initialize
    @element = 'text'
    @sentence = Element.new('sentence')
    @tip = Element.new('translation')
  end

  def build_by_sentence_and_tip(sentence, tip)
    @sentence.text = sentence
    @tip.text = tip
    self
  end

  private
  def sub_elements
    [@sentence, @tip]
  end
end
class SSelectPhrases<Block
  def initialize(attributes={})
    @attributes ={mode: 'strikethrough'}
    @element ='select-phrases'
    @options=[]
  end

  def build_by_sentence(sentence)
    def a_option(text)
      option = @opt.clone
      option.text = text
      option
    end

    words = sentence.split(/\s/)
    words.each { |word| @options<<a_option(word) }
  end
end
