
require 'xcodeproj'
require_relative '../project/general'
require_relative '../project/signing'

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

            end
        end
    end
end
