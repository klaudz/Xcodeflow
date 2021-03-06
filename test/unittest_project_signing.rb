#!/usr/bin/ruby

require_relative '../xcodeflow'
require 'test/unit'

class SigningTest < Test::Unit::TestCase

    @project_path
    @project

    def setup
        @project_path = File.join(__dir__, "TestProject/XcodeflowTest.xcodeproj")
        @project = Xcodeflow::Project.open(@project_path)
        @target = @project.targets.select { |target|
            target.name == "XcodeflowTest"
        }.first
    end

    def test_get_signing
    
        signing = @target.xcf_signing("Release")
        assert_not_nil(signing)
    
        assert_equal("3VR2JM3236",              signing.team_id)
        assert_equal("me.klaudz.XcodeflowTest", signing.bundle_identifier)
        assert_equal("",                        signing.provision_profile_specifier)
        assert_equal("iPhone Distribution",     signing.signing_certificate_identity)
        assert_equal(true,                      signing.auto_manage_signing)
    
    end

    def test_signing_with_conditions

        signing = @target.xcf_signing("Release")
        assert_not_nil(signing)

        signing_certificate_identity_dict = {}
        signing.signing_certificate_identity { |condition, value|
            signing_certificate_identity_dict[condition] = value
        }
        assert_equal({
            nil => "iPhone Distribution",
            "sdk=iphonesimulator*" => "Apple Distribution: Klaudz Liang (3VR2JM3236)"
        }, signing_certificate_identity_dict)

    end

end
