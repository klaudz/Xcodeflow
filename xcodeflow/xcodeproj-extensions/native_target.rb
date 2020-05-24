
require 'xcodeproj'
require_relative '../project/general'
require_relative '../project/signing'

module Xcodeproj
    class Project
        module Object

            class AbstractTarget
                
                def xcodeflow_general(build_configuration_name)
                    Xcodeflow::Project::General.new(self, build_configuration_name)
                end

                def xcodeflow_signing(build_configuration_name)
                    Xcodeflow::Project::Signing.new(self, build_configuration_name)
                end

            end
        end
    end
end
