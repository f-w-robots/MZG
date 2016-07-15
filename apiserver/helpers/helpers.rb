module Sinatra
  module App
    module Helpers
      def attribute attr_name, attr, comma
        result = "\"#{attr_name}\": "
        if attr.is_a?(String)
          result += "\"#{attr.gsub('"', '\"').gsub("\n",'\n')}\""
        elsif attr.nil?
          result += '""'
        elsif attr.is_a?(Hash) || attr.is_a?(Array)
          result += attr.to_json
        else
          result += attr.to_s
        end
        result += ',' if comma
        result
      end
    end
  end
end
