
require 'xcodeproj'
require_relative '../project/general'
require_relative '../project/signing'

module Xcodeproj
    class Project
        module Object

            class AbstractTarget

                attr_reader :xcf_general
                def xcf_general(build_configuration_name)
                    unless @xcf_general
                        @xcf_general = Xcodeflow::Project::General.new(self, build_configuration_name)
                    end
                    @xcf_general
                end

                attr_reader :xcf_signing
                def xcf_signing(build_configuration_name)
                    unless @xcf_signing
                        @xcf_signing = Xcodeflow::Project::Signing.new(self, build_configuration_name)
                    end
                    @xcf_signing
                end

            end
        end
    end
end
