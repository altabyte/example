module Magento
  class Store < Base
    class << self
      def list(*args)
        results = commit("list", *args)
        results.collect do |result|
          new(result)
        end
      end

      def find_by_view_code(code)
        list().select { |r| r.code == code }.first
      end
    end
  end
end
