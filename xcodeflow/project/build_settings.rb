
require 'xcodeproj'

module Xcodeflow
    class Project < Xcodeproj::Project

        class BuildSettings

            attr_reader :target, :build_configuration
            
            def initialize(target, build_configuration_name)
                @target = target
                @build_configuration = target.build_configurations.select { |build_configuration|
                    build_configuration.name == build_configuration_name
                }.first
            end

            def [](key)
                @build_configuration.build_settings[key]
            end
            def []=(key, value)
                @build_configuration.build_settings[key] = value
            end

            def setting(key)
                self[key]
            end

            def set_setting(key, value)
                self[key] = value
            end

            def resolve_setting(key)
                @build_configuration.resolve_build_setting(key)
            end

        end
    end
end