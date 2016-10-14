class HsCode < ActiveRecord::Base
  attr_accessible :code, :description

  def autocomplete_value
    self.code + ':' + self.description
  end
end
