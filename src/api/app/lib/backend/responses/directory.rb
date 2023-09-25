module Backend
  module Responses
    class Directory < Backend::Responses::Base
      attr_reader 

      def initialize(opts = {})
        @root = 'directory'
        @attributes = ['name', 'rev', 'vrev', 'srcmd5', 'error']
        @arrays = { entry: Backend::Responses::Directory::Entry }
        @objects = { linkinfo: Backend::Responses::Linkinfo, serviceinfo: Backend::Responses::Serviceinfo }
        super
      end
    end
  end
end
