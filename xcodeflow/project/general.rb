
require 'xcodeproj'

module Xcodeflow
    class Project < Xcodeproj::Project

        class General

            attr_reader :target, :build_configuration
            @xcf_build_settings
            @xcf_info
            
            def initialize(target, build_configuration_name)
                @target = target
                @build_configuration = target.build_configurations.select { |build_configuration|
                    build_configuration.name == build_configuration_name
                }.first
                @xcf_build_settings = @target.xcf_build_settings(build_configuration_name)
                @xcf_info = @target.xcf_info(build_configuration_name)
            end

            #pragma mark - Attributes
            #pragma mark - Attributes - Identity

            attr_accessor :display_name, :bundle_identifier, :version, :build
            def display_name
                _resolve_property("CFBundleDisplayName", "PRODUCT_NAME")
            end
            def display_name=(value)
                _set_property("CFBundleDisplayName", "PRODUCT_NAME", value)
            end

            attr_accessor :bundle_identifier
            def bundle_identifier
                _resolve_property("CFBundleIdentifier", "PRODUCT_BUNDLE_IDENTIFIER")
            end
            def bundle_identifier=(value)
                _set_property("CFBundleIdentifier", "PRODUCT_BUNDLE_IDENTIFIER", value)
            end

            attr_accessor :version
            def version
                _resolve_property("CFBundleShortVersionString", "MARKETING_VERSION")
            end
            def version=(value)
                _set_property("CFBundleShortVersionString", "MARKETING_VERSION", value)
            end

            attr_accessor :build
            def build
                _resolve_property("CFBundleVersion", "CURRENT_PROJECT_VERSION")
            end
            def build=(value)
                _set_property("CFBundleVersion", "CURRENT_PROJECT_VERSION", value)
            end

            #pragma mark - Attributes - Deployment Info

            attr_accessor :deployment_target
            def deployment_target
                @xcf_build_settings.resolve_setting("IPHONEOS_DEPLOYMENT_TARGET")
            end
            def deployment_target=(value)
                @xcf_build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = value
            end

            #pragma mark - Attributes - App Icons and Launch Images

            attr_reader :app_icons_source, :app_icons_paths
            def app_icons_source
                @xcf_build_settings.resolve_setting("ASSETCATALOG_COMPILER_APPICON_NAME")
            end
            def app_icons_paths
                source = app_icons_source
                return nil if source.nil?
                paths = []
                resources_build_phase = @target.resources_build_phase
                if resources_build_phase
                    xcassets_files = resources_build_phase.files.select { |file|
                        file.file_ref.real_path.to_s.end_with?('xcassets')
                    }
                    xcassets_files.each { |file|
                        path = File.join(file.file_ref.real_path.to_s, app_icons_source + ".appiconset")
                        if File.directory?(path)
                            paths.push(path)
                        end
                    }
                end
                return paths
            end

            #pragma mark - Helpers

            def _resolve_property(info_property_key, build_setting_key)
                property = @xcf_info.resolve_property(info_property_key)
                return property unless property.nil?
                property = @xcf_build_settings.resolve_setting(build_setting_key)
                return property
            end
            private :_resolve_property

            def _set_property(info_property_key, build_setting_key, property)
                @xcf_build_settings[build_setting_key] = property
                if @xcf_info.expand_build_settings_in_info_plist
                    @xcf_info[info_property_key] = "$(#{build_setting_key})"
                else
                    @xcf_info[info_property_key] = property
                end
            end
            private :_set_property

            def save
                @target.project.save
                @xcf_info.save_info_plist
            end

        end
    end
end
