
require 'xcodeproj'
require_relative '../project/general'
require_relative '../project/signing'
require_relative '../project/info'
require_relative '../project/build_settings'

module Xcodeproj
    class Project
        module Object

            class AbstractTarget

                @xcf_generals_cache
                def xcf_general(build_configuration_name)
                    @xcf_generals_cache = {} unless @xcf_generals_cache
                    general = @xcf_generals_cache[build_configuration_name]
                    unless general
                        general = Xcodeflow::Project::General.new(self, build_configuration_name)
                        @xcf_generals_cache[build_configuration_name] = general
                    end
                    general
                end

                @xcf_signings_cache
                def xcf_signing(build_configuration_name)
                    @xcf_signings_cache = {} unless @xcf_signings_cache
                    signing = @xcf_signings_cache[build_configuration_name]
                    unless signing
                        signing = Xcodeflow::Project::Signing.new(self, build_configuration_name)
                        @xcf_signings_cache[build_configuration_name] = signing
                    end
                    signing
                end

                @xcf_infos_cache
                def xcf_info(build_configuration_name)
                    @xcf_infos_cache = {} unless @xcf_infos_cache
                    info = @xcf_infos_cache[build_configuration_name]
                    unless info
                        info = Xcodeflow::Project::Info.new(self, build_configuration_name)
                        @xcf_infos_cache[build_configuration_name] = info
                    end
                    info
                end

                @xcf_build_settings_cache
                def xcf_build_settings(build_configuration_name)
                    @xcf_build_settings_cache = {} unless @xcf_build_settings_cache
                    build_settings = @xcf_build_settings_cache[build_configuration_name]
                    unless build_settings
                        build_settings = Xcodeflow::Project::BuildSettings.new(self, build_configuration_name)
                        @xcf_build_settings_cache[build_configuration_name] = build_settings
                    end
                    build_settings
                end

            end
        end
    end
end
