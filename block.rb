class Block
  def initialize
    @string = nil
  end

  def to_s
    @string.gsub!('<', '&lt;')
    @string.gsub!('>', '&gt;')
    @string.to_s
  end
end