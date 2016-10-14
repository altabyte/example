module Utils
  def self.is_numeric(o)
    true if Integer(o) rescue false
  end
end