module Backend
  module Responses
    class Directory
      class Entry < Backend::Responses::Base

        def initialize(opts = {})
          @root = 'entry'
          @attributes = ['name', 'md5', 'hash', 'size', 'mtime', 'error', 'id', 'originproject', 'originpackage']
          super
        end
      end
    end
  end
end
