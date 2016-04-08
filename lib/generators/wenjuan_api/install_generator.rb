module WenjuanApi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Install Wenjuan api support files'
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template 'config/wenjuan_api.yml'
      end
    end
  end
end
