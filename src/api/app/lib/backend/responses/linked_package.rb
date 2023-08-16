module Backend
  module Responses
    class LinkedPackage < Backend::Responses::Base

      def initialize(content)
        @root = 'linked'
        @attributes = ['project', 'package']
        super
      end
    end
  end
end
