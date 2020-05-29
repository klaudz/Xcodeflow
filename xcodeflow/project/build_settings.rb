
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

            def _array_setting(key)
                setting = self[key]
                if setting.is_a?(String)
                    # If `setting` is `String` type, convert it to `Array` type
                    setting = setting.empty? ? [] : [ setting ]
                end
                setting
            end
            private :_array_setting

            def _array_setting_by_split_string_setting(string_setting)
                # Note:
                #   The implementation is copied from
                #   `Xcodeproj::Project::Object::XCBuildConfiguration.split_build_setting_array_to_string`
                regexp = / *((['"]?).*?[^\\]\2)(?=( |\z))/
                string.scan(regexp).map(&:first)
            end
            private :_array_setting_by_split_string_setting

            def array_setting_add_items(key, items)
                array_setting = _array_setting(key)
                if array_setting.nil?
                    array_setting = [ '$(inherited)' ]
                end
                case items
                when String
                    array_setting.push(items)
                when Array
                    array_setting.concat(items)
                end
                self[key] = array_setting
            end

        end
    end
end