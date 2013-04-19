require './course.rb'
class SDrapDrop < Block
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