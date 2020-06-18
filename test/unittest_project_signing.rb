#!/usr/bin/ruby

require_relative '../xcodeflow'
require 'test/unit'

class SigningTest < Test::Unit::TestCase

    @project_path
    @project

    def setup
        @project_path = File.join(__dir__, "TestProject/XcodeflowTest.xcodeproj")
        @project = Xcodeflow::Project.open(@project_path)
    end

    def test_get_signing

        target = @project.targets.select { |target|
            target.name == "XcodeflowTest"
        }.first
        assert_not_nil(target)
    
        signing = target.xcf_signing("Release")
        assert_not_nil(signing)
    
        assert_equal("3VR2JM3236",              signing.team_id)
        assert_equal("me.klaudz.XcodeflowTest", signing.bundle_identifier)
        assert_equal("",                        signing.provision_profile_specifier)
        assert_equal("iPhone Distribution",     signing.signing_certificate_identity)
        assert_equal(true,                      signing.auto_manage_signing)
    
    end

end
