
require 'xcodeproj'
require_relative 'project/general'
require_relative 'project/signing'
require_relative 'xcodeproj-extensions/native_target.rb'

module Xcodeflow

    class Project < Xcodeproj::Project
        
        def xcf_scheme_names
            scheme_names = Xcodeflow::Project.schemes(@path)
            scheme_names
        end

        def xcf_schemes
            scheme_names = Xcodeflow::Project.schemes(@path)
            schemes = scheme_names.map { |name|
                scheme_path = File.join(Xcodeproj::XCScheme.shared_data_dir(@path), name + ".xcscheme")
                scheme = Xcodeproj::XCScheme.new(scheme_path)
                scheme
            }
            schemes
        end

    end

end
