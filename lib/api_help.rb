require "api_help/version"
require "active_record/api_help_overrides"

module ApiHelp
  extend ActiveSupport::Concern

  included do
    cattr_accessor :api_help_methods

    # Get scopes for activerecord descendant
    if self.is_a?(ActiveRecord::Base)

    end

    def self.api_help_method(method_name, description, opts = {})
      # puts "[api_help_method] #{self.to_s}: #{method_name}"
      #
      if opts[:class]
        klass = opts[:class]
      else
        klass = self
      end

      @@api_help_methods ||= {}
      api_help_methods[klass] ||= []
      api_help_methods[klass] << OpenStruct.new({ name: method_name.to_s, description: description })
    rescue => e
      raise e if !Rails.env.production?
      puts e.to_s
      puts e.backtrace[0..30].join("\n")
    end

    def self.api_help(search = nil, instance: nil)
      @@api_help_methods ||= {}

      search = search.to_s if search.is_a?(Symbol)

      # Search for definitions for this class and all its ancestors (included Modules as well)
      methods = ([self] + ancestors).map { |klass| api_help_methods[klass] }.flatten.compact.uniq

      if !methods.any?
        puts "No help configured"
        return
      end

      puts "===============================================".white.on_magenta
      puts "API Reference for class #{self.name}".white.on_magenta
      puts "===============================================".white.on_magenta

      if ancestors.include?(ActiveRecord::Base)
        if self.reflections.any?
          relations = self.reflections.keys
          relations = relations.select { |r| r.to_s.downcase[search.downcase] } if search # Apply filtering

          if relations.any?
            puts ""
            puts "RELATIONS:"
            puts "-----------------"

            relations.sort_by { |k| k }.each { |relation|
              puts "– #{relation}"
            }
          end
        end

        scope_meta = ([self] + ancestors).map { |klass| klass.try(:scope_names) }.flatten.compact.uniq
        scopes = scope_meta.map { |m| m.keys }.flatten
        scopes = scopes.select { |r| r.to_s.downcase[search.downcase] } if search # Apply filtering

        if scopes.any?
          puts ""
          puts "SCOPES:"
          puts "-----------------"
          scopes.sort_by { |k| k }.each { |scope|
            scope_params = scope_meta.select { |r| r.select { |k, v| k == scope } }.flatten.first[scope]

            if scope_params and scope_params.any?
              scope_params = "(#{scope_params.map { |r| r[1] }.join(', ')})"
            else
              scope_params = ""
            end

            puts ": #{scope}#{scope_params}"
          }
        end
      end

      puts ""
      puts "METHODS:"
      puts "-----------------"

      methods = methods.select { |r| r.name.to_s.downcase[search.downcase] } if search # Apply filtering

      if methods.any?
        methods.sort_by { |m| m.name }.each_with_index { |m, num|
          is_static_method = respond_to?(m.name)
          method_object = is_static_method ? self.method(m.name) : (instance ? instance.method(m.name) : nil)
          comment = ""
          params = ""

          if method_object
            comment = method_object.comment.gsub('# ', '').squish + " "
            comment = "" if m.description[comment.squish]

            params = method_object.parameters.map { |block| "#{block[1]} (#{block[0]})" }.join(", ")
            mock_params = method_object.parameters.map { |block| block[1] }.join(", ")
          else
            puts "Method object not found for method #{m.name}. Call #api_help on an instance of #{self.to_s}".red.on_yellow
          end

          print "self.".light_black.on_light_white if is_static_method
          print "#{m.name}".black.on_white
          print "(#{mock_params})".red.on_white
          print ": #{comment.gsub('# ', '')}#{m.description}. \n"

          if params.size > 1
            print "Parameters: ".green
            print "#{params}\n\n"
          else
            print "Without parameters\n\n".light_black
          end
        }
      end

      nil
    end
  end

  def api_help(search = nil)
    self.class.api_help(search, instance: self)
  end

end
