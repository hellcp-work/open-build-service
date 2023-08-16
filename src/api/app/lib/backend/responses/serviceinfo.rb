module Backend
  module Responses
    class Serviceinfo < Backend::Responses::Base

      def initialize(content)
        @root = 'serviceinfo'
        @attributes = ['code', 'xsrcmd5', 'lsrcmd5', 'lxsrcmd5']
        @items = ['error']
        super
      end
    end
  end
end
