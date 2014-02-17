require 'env_bang'

class ENV_BANG
  class Railtie < Rails::Railtie
    def env_rb_file
      File.join(Rails.root.to_s, 'config/env.rb')
    end

    config.before_configuration do
      if File.exists?(env_rb_file)
        load env_rb_file
      else
        Rails.logger.warn "ENV! could not find your environment variable configuration. Please create #{env_rb_file} to set up environment variables at Rails boot."
      end
    end
  end
end
