module Backend
  module ObjectApi
    module Sources
      # Class that connect to endpoints related to source packages
      module Package
        extend Backend::ConnectionHelper

        # Returns a file list of the sources for a package
        # @param options [Hash] Parameters to pass to the backend.
        # @return [String]
        def self.files(project_name, package_name, options = {})
          Backend::Responses::Directory.parse(http_get(['/source/:project/:package', project_name, package_name], params: options, accepted: [:expand, :rev, :view]))
        end
      end
    end
  end
end
