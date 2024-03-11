module Backend::Models
  class Statuscount < Base
    include HappyMapper

    tag :statuscount
    attribute :code, String
    attribute :count, Integer
  end
end
