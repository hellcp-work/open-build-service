module Backend
  module Responses
    class Base

      def initialize(opts = {})
        [:root, :attributes, :items, :objects, :arrays].each do |type|
          self.class.send(:attr_reader, type)
        end

        @attributes&.each do |attribute|
          self.class.send(:attr_accessor, attribute)
        end

        @items&.each do |item|
          self.class.send(:attr_accessor, item)
        end

        @objects&.each do |object, object_class|
          self.class.send(:attr_accessor, object)
        end

        @arrays&.each do |array, array_class|
          self.class.send(:attr_accessor, array.to_s.pluralize)
        end

        opts.each do |opt, val|
          send("#{opt}=", val)
        end
      end

      def xml
        Nokogiri::XML::Builder.new do |xml|
          attrs = @attributes&.to_h { |a| [a, send("#{a}")] }.compact
          xml.send(@root, attrs) do
            @items&.each do |item|
              xml.send(item, send("#{item}")) if send("#{item}")
            end

            @objects&.each do |object, object_class|
              o = send("#{object}")
              xml.parent << Nokogiri.XML(o.xml).root if o
            end

            @arrays&.each do |array, array_class|
              arrays_value = send("#{array.to_s.pluralize}")
              arrays_value&.each do |a|
                xml.parent << Nokogiri.XML(a.xml).root
              end
            end
          end
        end.to_xml
      end

      def self.parse(content)
        instance = self.new()
        doc = content.is_a?(String) ? Nokogiri::XML(content).xpath(instance.root) : content

        instance.attributes&.each do |attribute|
          instance.send("#{attribute}=", doc.attribute(attribute)&.value)
        end

        instance.items&.each do |item|
          instance.send("#{item}=", doc.xpath(item)&.map { |e| e.content })
        end

        instance.objects&.each do |object, object_class|
          value = doc.xpath(object.to_s).empty? ? nil : object_class.parse(doc.xpath(object.to_s))
          instance.send("#{object.to_s}=", value)
        end

        instance.arrays&.each do |array, array_class|
          instance.send("#{array.to_s.pluralize}=", doc.xpath(array.to_s).map {|a| array_class.parse(a) })
        end

        instance
      end
    end
  end
end
