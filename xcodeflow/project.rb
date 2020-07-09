
require 'xcodeproj'
require_relative 'project/general'
require_relative 'project/signing'
require_relative 'project/info'
require_relative 'project/build_settings'
require_relative 'scheme'
require_relative 'xcodeproj-extensions/native_target.rb'

module Xcodeflow

    class Project < Xcodeproj::Project
        
        #pragma mark - Schemes

        def xcf_shared_schemes
            _xcf_schemes_in_dir(Xcodeflow::Scheme.shared_data_dir(@path))
        end

        def xcf_user_schemes(user = nil)
            _xcf_schemes_in_dir(Xcodeflow::Scheme.user_data_dir(@path, user))
        end

        def xcf_current_user_schemes(create_unless_exists = false)
            schemes = _xcf_schemes_in_dir(Xcodeflow::Scheme.user_data_dir(@path))
            return schemes unless create_unless_exists
            return schemes if schemes.count > 0
            recreate_user_schemes
            schemes = _xcf_schemes_in_dir(Xcodeflow::Scheme.user_data_dir(@path))
            return schemes
        end

        def _xcf_schemes_in_dir(xcschemes_dir)
            schemes = Dir[File.join(xcschemes_dir, "*.xcscheme")].map { |scheme_path|
                name = File.basename(scheme_path, '.xcscheme')
                scheme = Xcodeflow::Scheme.new(scheme_path, name)
                scheme
            }
            schemes
        end
        private :_xcf_schemes_in_dir

        #pragma mark - Schemes to Targets

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
