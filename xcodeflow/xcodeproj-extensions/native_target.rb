
require 'xcodeproj'

module Xcodeproj
    class Project
        module Object

            class AbstractTarget
                
                def xcodeflow_general(build_configuration_name)
                    Xcodeflow::Project::General.new(self, build_configuration_name)
                end
            end
        end
    end
end
