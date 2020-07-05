
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

            def each_conditional_setting(key) # { |key, condition, value| }
                regexp = /^#{key}(?:\[(.+)\])?$/
                settings = @build_configuration.build_settings.select { |k, v|
                    match_data = k.match(regexp)
                    if match_data.nil?
                        false
                    else
                        condition = match_data[1]
                        yield(k, condition, v)
                        true
                    end
                }
                settings
            end

            def resolve_setting(key)
                temp_build_setting_keys = _configure_product_info_build_settings_temporarily
                setting = @build_configuration.resolve_build_setting(key, @target)
                _restore_build_settings(temp_build_setting_keys)
                setting
            end

            def _configure_product_info_build_settings_temporarily
                temp_build_setting_keys = []
                # See:
                #   Product Information Build Settings
                #   https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html

                # TARGET_NAME
                if @build_configuration.resolve_build_setting("TARGET_NAME", @target).nil? and @target
                    @build_configuration.build_settings["TARGET_NAME"] = @target.name
                    temp_build_setting_keys.push("TARGET_NAME")
                end
                # PROJECT_DIR
                if @build_configuration.resolve_build_setting("PROJECT_DIR", @target).nil?
                    @build_configuration.build_settings["PROJECT_DIR"] = @build_configuration.project.project_dir.to_s
                    temp_build_setting_keys.push("PROJECT_DIR")
                end
                # EXECUTABLE_NAME
                if @build_configuration.resolve_build_setting("EXECUTABLE_NAME", @target).nil?
                    @build_configuration.build_settings["EXECUTABLE_NAME"] = "$(EXECUTABLE_PREFIX)$(PRODUCT_NAME)$(EXECUTABLE_SUFFIX)"
                    temp_build_setting_keys.push("EXECUTABLE_NAME")
                end

                return temp_build_setting_keys
            end
            def _restore_build_settings(temp_build_setting_keys)
                return if temp_build_setting_keys.nil?
                temp_build_setting_keys.each { |key|
                    @build_configuration.build_settings.delete(key)
                }
            end
            private :_configure_product_info_build_settings_temporarily, :_restore_build_settings

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