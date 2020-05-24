
require 'xcodeproj'

module Xcodeflow
    class Project < Xcodeproj::Project

        class Signing

            attr_reader :target, :build_configuration
            
            def initialize(target, build_configuration_name)
                @target = target
                @build_configuration = target.build_configurations.select { |build_configuration|
                    build_configuration.name == build_configuration_name
                }.first
                _load_info
            end

            attr_reader :team_id, :bundle_identifier, :provision_profile, :signing_certificate

            def _load_info
                @team_id = @build_configuration.resolve_build_setting("DEVELOPMENT_TEAM")
                @bundle_identifier = @build_configuration.resolve_build_setting("PRODUCT_BUNDLE_IDENTIFIER")
                @provision_profile = @build_configuration.resolve_build_setting("PROVISIONING_PROFILE_SPECIFIER")
                @signing_certificate = @build_configuration.resolve_build_setting("CODE_SIGN_IDENTITY")
            end
            private :_load_info

        end
    end
end
