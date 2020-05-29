
require 'xcodeproj'
require_relative 'project/general'
require_relative 'project/signing'
require_relative 'scheme'
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
                scheme_path = File.join(Xcodeflow::Scheme.shared_data_dir(@path), name + ".xcscheme")
                scheme = Xcodeflow::Scheme.new(scheme_path, name)
                scheme
            }
            schemes
        end

        def xcf_target_for_scheme(scheme)
            entries = scheme.build_action.entries
            return nil if entries.nil? or entries.count == 0
            buildable_references = entries.first.buildable_references
            return nil if buildable_references.nil? or buildable_references.count == 0
            target_name = buildable_references.first.target_name
            return nil if target_name.nil?
            target = self.targets.select { |target|
                target.name == target_name
            }.first
            return target
        end

    end

end
