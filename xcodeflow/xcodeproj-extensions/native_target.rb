
require 'xcodeproj'
require_relative '../project/general'
require_relative '../project/signing'

module Xcodeproj
    class Project
        module Object

            class AbstractTarget

                attr_reader :xcodeflow_general
                def xcodeflow_general(build_configuration_name)
                    unless @xcodeflow_general
                        @xcodeflow_general = Xcodeflow::Project::General.new(self, build_configuration_name)
                    end
                    @xcodeflow_general
                end

                attr_reader :xcodeflow_signing
                def xcodeflow_signing(build_configuration_name)
                    unless @xcodeflow_signing
                        @xcodeflow_signing = Xcodeflow::Project::Signing.new(self, build_configuration_name)
                    end
                    @xcodeflow_signing
                end

            end
        end
    end
end
