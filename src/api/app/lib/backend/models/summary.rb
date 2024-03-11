module Backend::Models
  class Summary < Base
    include HappyMapper

    tag :summary
    has_many :statuscounts, Backend::Models::Statuscount, tag: :statuscount
  end
end
