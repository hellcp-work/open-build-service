module Backend::Models
  class Result < Base
    include HappyMapper
    attr_accessor :repository_in_db

    tag :result
    attribute :project, String
    attribute :repository, String
    attribute :arch, String
    attribute :code, String
    attribute :dirty, String
    attribute :state, String
    attribute :details, String
    element :summary, Backend::Models::Summary
    has_many :statuses, Backend::Models::Status, tag: :status
  end
end
