# frozen_string_literal: true

module Tally
  class Engine < ::Rails::Engine

    isolate_namespace Tally

    engine_name "tally"

    # Run migrations in the main app without copying
    # From: https://content.pivotal.io/blog/leave-your-migrations-in-your-rails-engines
    initializer "tally.append_migrations" do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    # Allow approved helpers to be included in the main app
    initializer "tally.expose_helpers" do |app|
      ActiveSupport.on_load :action_controller do
        ActionController::Base.helper Tally::IncrementHelper
      end
    end

  end
end
