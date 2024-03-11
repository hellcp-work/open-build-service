module Backend::Models
  class Status < Base
    include HappyMapper

    tag :status
    attribute :package, String
    attribute :code, String
    has_one :details, String
  end
end
