
require 'xcodeproj'

module Xcodeflow
    class Project < Xcodeproj::Project

        class General

            attr_reader :target, :build_configuration
            
            def initialize(target, build_configuration_name)
                @target = target
                @build_configuration = target.build_configurations.select { |build_configuration|
                    build_configuration.name == build_configuration_name
                }.first
                @infoplist_updated = false
                _load_info
            end

            @infoplist_updated
            attr_reader :infoplist_name, :infoplist_path, :infoplist
            attr_reader :expand_build_settings_in_infoplist

            attr_accessor :display_name, :bundle_identifier, :version, :build
            def display_name=(value)
                _update_infoplist_setting("CFBundleDisplayName", "PRODUCT_NAME", value)
                @display_name = value
            end
            def bundle_identifier=(value)
                _update_infoplist_setting("CFBundleIdentifier", "PRODUCT_BUNDLE_IDENTIFIER", value)
                @bundle_identifier = value
            end
            def version=(value)
                _update_infoplist_setting("CFBundleShortVersionString", "MARKETING_VERSION", value)
                @version = value
            end
            def build=(value)
                _update_infoplist_setting("CFBundleVersion", "CURRENT_PROJECT_VERSION", value)
                @build = value
            end

            attr_accessor :deployment_target
            def deployment_target=(value)
                @build_configuration.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = value
                @deployment_target = value
            end

            attr_reader :app_icons_source, :app_icons_paths

            def _load_info
                _load_info_for_infoplist
                _load_info_from_infoplist
                @deployment_target = @build_configuration.resolve_build_setting("IPHONEOS_DEPLOYMENT_TARGET")
                _load_app_icons
            end
            private :_load_info

            def _load_info_for_infoplist
                @infoplist_name = @build_configuration.resolve_build_setting("INFOPLIST_FILE")
                # if File.absolute_path?(@infoplist_name)
                    # @infoplist_path = @infoplist_name
                # else
                    @infoplist_path = File.join(@build_configuration.project.project_dir, @infoplist_name)
                # end
                expand_string = @build_configuration.resolve_build_setting("INFOPLIST_EXPAND_BUILD_SETTINGS")
                if expand_string.nil? or expand_string == "YES"
                    @expand_build_settings_in_infoplist = true
                else
                    @expand_build_settings_in_infoplist = false
                end
            end
            private :_load_info_for_infoplist

            def _load_info_from_infoplist
                path = @infoplist_path
                unless File.file?(path)
                    return
                end
                @infoplist = Xcodeproj::Plist.read_from_path(path)
                @display_name = _resolve_infoplist_setting("CFBundleDisplayName")
                @bundle_identifier = _resolve_infoplist_setting("CFBundleIdentifier")
                @version = _resolve_infoplist_setting("CFBundleShortVersionString")
                @build = _resolve_infoplist_setting("CFBundleVersion")
            end
            private :_load_info_from_infoplist

            def _load_app_icons
                @app_icons_source = @build_configuration.resolve_build_setting("ASSETCATALOG_COMPILER_APPICON_NAME")
                @app_icons_paths = []
                if @app_icons_source.nil?
                    return
                end
                resources_build_phase = @target.resources_build_phase
                if resources_build_phase
                    xcassets_files = resources_build_phase.files.select { |file|
                        file.file_ref.real_path.to_s.end_with?('xcassets')
                    }
                    xcassets_files.each { |file|
                        app_icons_path = File.join(file.file_ref.real_path.to_s, @app_icons_source + ".appiconset")
                        if File.directory?(app_icons_path)
                            @app_icons_paths.push(app_icons_path)
                        end
                    }
                end
            end
            private :_load_app_icons

            def _resolve_infoplist_setting(key)
                value = @infoplist[key]
                return value unless @expand_build_settings_in_infoplist
                return value unless value
                value.gsub!(/\$\(\w+\)/) { |match|
                    subkey = /\w+/.match(match)[0]
                    subvalue = @build_configuration.resolve_build_setting(subkey)
                    return subvalue
                }
                return value
            end
            private :_resolve_infoplist_setting

            def _update_infoplist_setting(infoplist_key, build_setting_key, value)
                @infoplist_updated = true
                @build_configuration.build_settings[build_setting_key] = value
                if @expand_build_settings_in_infoplist
                    @infoplist[infoplist_key] = "$(#{build_setting_key})"
                else
                    @infoplist[infoplist_key] = value
                end
            end
            private :_update_infoplist_setting

            def save
                @target.project.save
                _save_infoplist
            end

            def _save_infoplist
                if @infoplist_updated
                    Xcodeproj::Plist.write_to_path(@infoplist, @infoplist_path)
                    @infoplist_updated = false
                end
            end
            protected :_save_infoplist

        end
    end
end
