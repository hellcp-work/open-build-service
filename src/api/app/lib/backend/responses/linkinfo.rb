module Backend
  module Responses
    class Linkinfo < Backend::Responses::Base

      def initialize(opts = {})
        @root = 'linkinfo'
        @attributes = ['project', 'package', 'rev', 'srcmd5', 'baserev', 'missingok', 'xsrcmd5', 'lsrcmd5', 'error', 'lastworking']
        @arrays = { linked: Backend::Responses::LinkedPackage }
        super
      end
    end
  end
end
