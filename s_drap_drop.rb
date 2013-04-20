require './course.rb'
class SDrapDrop < Block
  def initialize(attributes={})
    @attributes = {
        orientation: nil,
        dropsign: '10'
    }
    @attributes.merge! attributes
    @question = Element.new('drop-text')
    @opt = Element.new('option')
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
    string_gen
    self.freeze
  end

  def sentence_with_percent(sentence, percent = 0.2)
    n = (sentence.split(/\s/).size * percent).to_i
    self.sentence_with_n(sentence, n)
  end

  private
  def string_gen
    @string = Element.new('drap-drop')
    @attributes.each_pair { |k, v| @string.add_attribute(k.to_s, v) }
    @string << @question
    @options.each { |option| @string << option }
  end
end


