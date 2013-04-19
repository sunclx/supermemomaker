require './item.rb'
class QA
  attr_reader :element

  def initialize(question=nil, answer=nil)
    @element =[Element.new('question'), Element.new('answer')]
    @q=@element[0].text = question.to_s
    @a=@element[1].text = answer.to_s

    def @q.<<(string)
      @q.text += string
    end

    def @a.<<(string)
      @a.text+=string
    end
  end

  def q
    @q.text
  end

  def q=(string)
    @q.text = string
  end

  def a
    @a.text
  end

  def a=(string)
    @a.text = string
  end
end