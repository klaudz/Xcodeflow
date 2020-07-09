
require 'xcodeproj'
require 'pathname'

module Xcodeflow

    class Workspace < Xcodeproj::Workspace
        
        def self.new_from_xcworkspace(path)
            workspace = super(path)
            workspace.xcf_path = Pathname.new(path).expand_path
            workspace
        end

        attr_accessor :xcf_path # TODO: Optimize `new_from_xcworkspace` and change `xcf_path` as `attr_reader`

    end

end
