module Backend
  module Responses
    class Base

      def initialize(content)
        @doc = content.is_a?(String) ? Nokogiri::XML(content).xpath(@root) : content
        
        @attributes&.each do |attribute|
          instance_variable_set(:"@#{attribute}", @doc.attribute(attribute)&.value)
          self.class.send(:attr_reader, attribute)
        end

        @items&.each do |item|
          instance_variable_set(:"@#{item}", @doc.xpath(item)&.map { |e| e.content })
          self.class.send(:attr_reader, item)
        end

        @objects&.each do |object, object_class|
          value = @doc.xpath(object.to_s).empty? ? nil : object_class.new(@doc.xpath(object.to_s))
          instance_variable_set(:"@#{object.to_s}", value)
          self.class.send(:attr_reader, object)
        end

        @arrays&.each do |array, array_class|
          instance_variable_set(:"@#{array.to_s.pluralize}", @doc.xpath(array.to_s).map {|a| array_class.new(a) })
          self.class.send(:attr_reader, array.to_s.pluralize)
        end
      end
    end
  end
end
