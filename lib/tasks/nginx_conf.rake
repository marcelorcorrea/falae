namespace :nginx_conf do
  desc 'Generate a nginx conf file'
  task :generate, [:config] => :environment do |task, args|
    class TemplateRenderer
      def self.empty_binding
        binding
      end

      def self.render(template_content, locals = {})
        b = empty_binding
        locals.each { |k, v| b.local_variable_set(k, v) }
        ERB.new(template_content).result(b)
      end
    end

    config_file_path = args.config || './.nginx-conf.yaml'
    config_file = YAML.load(ERB.new(File.read(config_file_path)).result)
    template_path = File.join(Rails.root, 'scripts', 'nginx', 'falae.conf.erb')
    template_content = File.read(template_path)

    nginx_conf_content = TemplateRenderer.render(template_content, config_file)
    nginx_conf_file_path = File.join(Rails.root, 'tmp', 'falae.conf')
    File.open(nginx_conf_file_path, 'wb') do |file|
      puts "Saving nginx conf file in #{nginx_conf_file_path}"
      file.write nginx_conf_content
    end
  end
end
