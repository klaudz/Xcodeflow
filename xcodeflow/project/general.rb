
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
                _load_info
            end

            attr_reader :infoplist_name, :infoplist_path
            attr_reader :display_name, :bundle_identifier, :version, :build
            attr_reader :deployment_target
            attr_reader :app_icons_source, :app_icons_paths

            def _load_info
                @infoplist_name = @build_configuration.resolve_build_setting("INFOPLIST_FILE")
                # if File.absolute_path?(@infoplist_name)
                    # @infoplist_path = @infoplist_name
                # else
                    @infoplist_path = File.join(@build_configuration.project.project_dir, @infoplist_name)
                # end
                _load_info_from_infoplist
                @deployment_target = @build_configuration.resolve_build_setting("IPHONEOS_DEPLOYMENT_TARGET")
                _load_app_icons
            end
            private :_load_info

            def _load_info_from_infoplist
                path = @infoplist_path
                unless File.file?(path)
                    return
                end
                plist = Xcodeproj::Plist.read_from_path(path)
                @display_name = plist["CFBundleDisplayName"]
                @bundle_identifier = plist["CFBundleIdentifier"]
                @version = plist["CFBundleShortVersionString"]
                @build = plist["CFBundleVersion"]
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

        end
    end
end
