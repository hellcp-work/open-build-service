module Webui
  module Packages
    class BadgeController < Packages::MainController
      before_action :set_project
      before_action :set_package

      def show
        opts = { package: @package.name, lastbuild: 1, arch: params[:architecture], repository: params[:repository] }.compact
        results = Backend::Models::Resultlist.fetch(@project.name, opts).results
        results = discard_non_relevant_results(results)
        badge = Badge.new(params[:type], results.map { |r| r.statuses }.flatten)
        send_data(badge.xml, type: 'image/svg+xml', disposition: 'inline')
      end

      private

      # discard results with excluded and disabled status
      # discard disabled with possible previous failed results
      def discard_non_relevant_results(results)
        results.reject { |r| @package.disabled_for?('build', r.repository, r.arch) }
      end
    end
  end
end
