
require 'xcodeproj'
require 'pathname'

module Xcodeflow
    class Project < Xcodeproj::Project

        class Info

            attr_reader :target, :build_configuration
            
            def initialize(target, build_configuration_name)
                @target = target
                @build_configuration = target.build_configurations.select { |build_configuration|
                    build_configuration.name == build_configuration_name
                }.first
                _load_info
                _load_properties_from_info_plist
            end

            attr_reader :info_plist_file, :info_plist_path
            def _load_info
                @info_plist_file = @build_configuration.resolve_build_setting("INFOPLIST_FILE")
                return unless @info_plist_file
                @info_plist_path = Pathname.new(@info_plist_file)
                unless @info_plist_path.absolute?
                    @info_plist_path = (@build_configuration.project.project_dir + @info_plist_file).realpath
                end
            end
            private :_load_info

            @info_plist_updated
            attr_accessor :info_plist_properties
            def _load_properties_from_info_plist
                @info_plist_updated = false
                return unless @info_plist_path
                return unless @info_plist_path.file?
                @info_plist_properties = Xcodeproj::Plist.read_from_path(@info_plist_path)
            end
            private :_load_properties_from_info_plist
            def save_info_plist
                return unless @info_plist_updated
                Xcodeproj::Plist.write_to_path(@info_plist_properties, @info_plist_path)
                @info_plist_updated = false
            end
            
            attr_accessor :expand_build_settings_in_infoplist
            def expand_build_settings_in_infoplist
                expand_string = @build_configuration.resolve_build_setting("INFOPLIST_EXPAND_BUILD_SETTINGS")
                if expand_string.nil? or expand_string == "YES"
                    return true
                else
                    return false
                end
            end
            def expand_build_settings_in_infoplist=(value)
                @build_configuration.build_settings["INFOPLIST_EXPAND_BUILD_SETTINGS"] = value.nil? ? nil : (value ? "YES" : "NO")
            end

            def [](key)
                return nil unless @info_plist_properties
                @info_plist_properties[key]
            end
            def []=(key, value)
                return unless @info_plist_properties
                @info_plist_properties[key] = value
                @info_plist_updated = true
            end

            def value(key)
                self[key]
            end

            def set_value(key, value)
                self[key] = value
            end

        end
    end
end
