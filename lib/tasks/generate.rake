namespace :operations do
  namespace :generate do
    namespace :json_rpc do
      desc "Generates Typescript client"
      task :ts, [:out] => :environment do |_, args|
        content = Operations::ClientGenerators::JsonRpc::TypeScript.new(ApplicationOperation.operations).call
        file = args[:out] || "#{Bundler.root}/tmp/client.ts"

        File.write(file, content)
      end
    end
  end
end
