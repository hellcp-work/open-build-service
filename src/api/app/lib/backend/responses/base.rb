module Backend
  module Responses
    class Base
      def initialize(opts = {})
        [:root, :attributes, :items, :objects, :arrays].each do |type|
          self.class.send(:attr_reader, type)
        end

        set_accessors

        opts.each do |opt, val|
          send("#{opt}=", val)
        end
      end

      class << self
        # Creates new instance of the class with the values taken from the passed xml document
        def parse(content)
          instance = new
          xml_document = content.is_a?(String) ? Nokogiri::XML(content).xpath(instance.root) : content

          assign_attributes(instance, xml_document)
          assign_items(instance, xml_document)
          assign_objects(instance, xml_document)
          assign_arrays(instance, xml_document)

          instance
        end

        private

        def assign_attributes(instance, xml_document)
          instance.attributes&.each do |attribute|
            instance.send("#{attribute}=", xml_document.attribute(attribute)&.value)
          end
        end

        def assign_items(instance, xml_document)
          instance.items&.each do |item|
            instance.send("#{item}=", xml_document.xpath(item)&.map(&:content))
          end
        end

        def assign_objects(instance, xml_document)
          instance.objects&.each do |object, object_class|
            value = xml_document.xpath(object.to_s).empty? ? nil : object_class.parse(xml_document.xpath(object.to_s))
            instance.send("#{object}=", value)
          end
        end

        def assign_arrays(instance, xml_document)
          instance.arrays&.each do |array, array_class|
            instance.send("#{array.to_s.pluralize}=", xml_document.xpath(array.to_s).map { |a| array_class.parse(a) })
          end
        end
      end

      # Creates a new xml based on the data in the instance of the class
      def xml
        Nokogiri::XML::Builder.new do |xml|
          attrs = @attributes&.index_with { |a| send("#{a}") }&.compact
          xml.send(@root, attrs) do
            build_items(xml)
            build_objects(xml)
            build_arrays(xml)
          end
        end.to_xml
      end

      private

      def set_accessors
        [@attributes, @items].compact.flatten.each do |attribute|
          self.class.send(:attr_accessor, attribute)
        end

        @objects&.each do |object, _object_class|
          self.class.send(:attr_accessor, object)
        end

        @arrays&.each do |array, _array_class|
          self.class.send(:attr_accessor, array.to_s.pluralize)
        end
      end

      def build_items(xml)
        @items&.each do |item|
          xml.send(item, send("#{item}")) if send("#{item}")
        end
      end

      def build_objects(xml)
        @objects&.each do |object, _object_class|
          object_value = send("#{object}")
          xml.parent << Nokogiri.XML(object_value.xml).root if object_value
        end
      end

      def build_arrays(xml)
        @arrays&.each do |array, _array_class|
          arrays_value = send("#{array.to_s.pluralize}")
          arrays_value&.each do |a|
            xml.parent << Nokogiri.XML(a.xml).root
          end
        end
      end
    end
  end
end
