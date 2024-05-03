module ActionBuildResultsService
  class ChartDataExtractor
    attr_accessor :actions

    def initialize(actions:)
      @actions = actions
    end

    def call
      return [] if @actions.blank?

      @actions.where(type: %i[submit maintenance_incident maintenance_release]).map do |action|
        sources = sources_from_action(action)
        next unless sources[:source_project].present? && sources[:source_package].present?

        package_build_results(sources[:source_package], sources[:source_project])
      end.flatten.compact
    end

    private

    def project_from_action(action)
      bs_request = BsRequest.find(action.bs_request_id)
      # consider staging project
      project_name = bs_request.staging_project_id.nil? ? action.source_project : bs_request.staging_project.name
      Project.find_by_name(project_name)
    end

    def sources_from_action(action)
      source_project = project_from_action(action)
      source_package = source_project.present? ? Package.find_by_project_and_name(source_project.name, action.source_package) : nil
      { source_project: source_project, source_package: source_package }
    end

    def package_build_results(source_package, source_project)
      results = Backend::Models::Resultlist.fetch(source_project, package: source_package, multibuild: 1, locallink: 1).group_by_package
      results.flat_map do |pkg, build_results|
        build_results.results.map do |result|
          {
            architecture: result.arch,
            repository: result.repository,
            status: result.statuses.first.code,
            package_name: pkg,
            project_name: source_project,
            repository_status: result.state,
            is_repository_in_db: result.repository_in_db
          }
        end
      end
    end
  end
end
