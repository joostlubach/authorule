require File.expand_path('..', __FILE__)

module Authorule

  class Railtie < Rails::Railtie

    generators do
      Dir[ File.expand_path('../generators/*/*_generator.rb', __FILE__) ].each do |path|
        require path
      end
    end

    rake_tasks do
      Dir[ File.expand_path('../tasks/**/*.rake', __FILE__) ].each do |path|
        load path
      end
    end

    initializer 'authorule.add_models_path' do |app|
      ActiveSupport::Dependencies.autoload_paths << File.expand_path('../app/models', __FILE__)
    end

  end

end