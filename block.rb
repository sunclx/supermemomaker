class Block
  def initialize(text=nil)
    @string = text
  end

  def to_s
    @string.gsub!('<', '&lt;')
    @string.gsub!('>', '&gt;')
    @string.to_s
  end
end