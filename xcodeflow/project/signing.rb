
require_relative '../provision'
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

            attr_accessor :team_id, :bundle_identifier, :provision_profile_specifier, :signing_certificate_identity
            def team_id=(value)
                @build_configuration.build_settings["DEVELOPMENT_TEAM"] = value
                @team_id = value
            end
            def bundle_identifier=(value)
                @build_configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = value
                @bundle_identifier = value
            end
            def provision_profile_specifier=(value)
                @build_configuration.build_settings["PROVISIONING_PROFILE_SPECIFIER"] = value
                @provision_profile_specifier = value
            end
            def signing_certificate_identity=(value)
                @build_configuration.build_settings["CODE_SIGN_IDENTITY"] = value
                @signing_certificate_identity = value
            end

            def _load_info
                @team_id = @build_configuration.resolve_build_setting("DEVELOPMENT_TEAM")
                @bundle_identifier = @build_configuration.resolve_build_setting("PRODUCT_BUNDLE_IDENTIFIER")
                @provision_profile_specifier = @build_configuration.resolve_build_setting("PROVISIONING_PROFILE_SPECIFIER")
                @signing_certificate_identity = @build_configuration.resolve_build_setting("CODE_SIGN_IDENTITY")
            end
            private :_load_info

            def update_from_provision(provision)
                self.team_id = provision.team_id
                self.bundle_identifier = provision.bundle_identifier
                self.provision_profile_specifier = provision.name ? provision.name : provision.uuid
                self.signing_certificate_identity = provision.certificates[0].name
            end

        end
    end
end
