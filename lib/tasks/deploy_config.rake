# frozen_string_literal: true

require "erb"
require "fileutils"

namespace :deploy do
  desc "Generate config/deploy.yml from template using environment variables"
  task :generate_config, [ :options ] => :environment do |task, args|
    options = parse_options(args[:options])
    template_path = Rails.root.join("config", "deploy.yml.template")
    output_path = Rails.root.join("config", "deploy.yml")

    unless File.exist?(template_path)
      puts "Error: Template file not found at #{template_path}"
      puts "Please create config/deploy.yml.template first."
      exit 1
    end

    # Read and process the template
    template_content = File.read(template_path)
    erb = ERB.new(template_content, trim_mode: "-")

    begin
      rendered_content = erb.result
    rescue => e
      puts "Error processing template: #{e.message}"
      exit 1
    end

    # Handle different output modes
    if options[:stdout]
      puts rendered_content
    else
      # Check if target file exists and warn
      if File.exist?(output_path) && !options[:force]
        print "Warning: #{output_path} already exists. Overwrite? [y/N]: "
        response = STDIN.gets.chomp.downcase
        unless %w[y yes].include?(response)
          puts "Aborted."
          exit 0
        end
      end

      # Write the file
      begin
        File.write(output_path, rendered_content)
        puts "Successfully generated #{output_path}"

        # Show which environment variables were used
        show_used_environment_variables
      rescue => e
        puts "Error writing file: #{e.message}"
        exit 1
      end
    end
  end

  desc "Show available environment variables for deploy config generation"
  task :show_env_vars do
    puts "Available environment variables for deploy configuration:"
    puts "(Only showing variables that correspond to TODO fields in the original deploy.yml)"
    puts

    env_vars = {
      "KAMAL_IMAGE" => "Container image name (default: willcodeforcoffee/startonaut)",
      "KAMAL_REGISTRY_USERNAME" => "Registry username",
      "KAMAL_WEB_SERVER" => "Web server hostname or IP address for deployment",
      "KAMAL_HOST" => "Application hostname for SSL (default: startonaut.com)",
      "KAMAL_SSH_USER" => "SSH user on KAMAL_WEB_SERVER to use"
    }

    env_vars.each do |var, description|
      current_value = ENV[var]
      status = current_value ? "✓ SET" : "  not set"
      puts "  #{var.ljust(25)} - #{description}"
      puts "    #{status}#{current_value ? ": #{current_value}" : ""}"
      puts
    end

    puts "Usage examples:"
    puts "  # Generate and print to stdout:"
    puts "  bundle exec rake deploy:generate_config[stdout]"
    puts
    puts "  # Generate file (with confirmation):"
    puts "  bundle exec rake deploy:generate_config"
    puts
    puts "  # Force overwrite without confirmation:"
    puts "  bundle exec rake deploy:generate_config[force]"
    puts
    puts "  # Set environment variables before running:"
    puts "  KAMAL_HOST=myapp.com KAMAL_WEB_SERVER=1.2.3.4 bundle exec rake deploy:generate_config"
  end

  private

  def parse_options(options_string)
    options = { stdout: false, force: false }

    return options if options_string.nil? || options_string.empty?

    option_parts = options_string.split(",").map(&:strip)

    option_parts.each do |option|
      case option.downcase
      when "stdout", "print"
        options[:stdout] = true
      when "force", "f"
        options[:force] = true
      else
        puts "Warning: Unknown option '#{option}'. Available options: stdout, force"
      end
    end

    options
  end

  def show_used_environment_variables
    puts
    puts "Environment variables used:"

    used_vars = [
      "KAMAL_IMAGE", "KAMAL_WEB_SERVER", "KAMAL_HOST",
      "KAMAL_REGISTRY_USERNAME", "KAMAL_SSH_USER"
    ]

    set_vars = used_vars.select { |var| ENV[var] }
    unset_vars = used_vars.reject { |var| ENV[var] }

    if set_vars.any?
      puts "  Set variables:"
      set_vars.each do |var|
        puts "    #{var} = #{ENV[var]}"
      end
    end

    if unset_vars.any?
      puts "  Using defaults for: #{unset_vars.join(', ')}"
    end

    puts
    puts "To see all available variables: bundle exec rake deploy:show_env_vars"
  end
end
