module Backend::Models
  class Resultlist < Base
    include HappyMapper
    attr_accessor :project

    tag :resultlist
    has_many :results, Backend::Models::Result, tag: :result

    def self.fetch(project, opts = {})
      xml = Backend::Api::BuildResults::Status.result_swiss_knife(project, opts)
      self.parse(xml).tap do |r|
        r.project = project
      end
    end

    def without_excluded
      copy = dup
      copy.results.each do |result|
        result.statuses.reject! { |s| %w[excluded disabled].include?(s.code) }
      end
      copy
    end

    def excluded_counter
      results.map(&:statuses).flatten.count { |s| %w[excluded disabled].include?(s.code) }
    end

    def group_by_package
      repositories_in_db?
      packages = results.map { |r| r.statuses.map{ |s| s.package } }.flatten.uniq
      packages.to_h do |package|
        list = dup
        list.results.each do |result|
          result.statuses.reject { |s| s.package != package }
        end
        [package, list]
      end
    end

    private

    def repositories_in_db?
      repo_arch = Project.find_by_name(project).repositories.joins(:architectures).pluck(:name, Arel.sql('architectures.name'))
      results.each do |r|
        r.repository_in_db = repo_arch.include?([r.repository, r.arch])
      end
    end
  end
end
