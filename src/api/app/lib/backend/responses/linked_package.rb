module Backend
  module Responses
    class LinkedPackage < Backend::Responses::Base
      def initialize(opts = {})
        @root = 'linked'
        @attributes = ['project', 'package']
        super
      end
    end
  end
end
