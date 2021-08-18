module Operations
  class Railtie < Rails::Railtie
    railtie_name :operations

    rake_tasks do
      Dir.glob("#{Operations.root}/lib/tasks/**/*.rake").each { |f| load f }
    end
  end
end
