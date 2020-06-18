#!/usr/bin/ruby

require_relative '../xcodeflow'
require 'test/unit'

class GeneralTest < Test::Unit::TestCase

    @project_path
    @project
    @target

    def setup
        @project_path = File.join(__dir__, "TestProject/XcodeflowTest.xcodeproj")
        @project = Xcodeflow::Project.open(@project_path)
        @target = @project.targets.select { |target|
            target.name == "XcodeflowTest"
        }.first
    end

    def test_get_identity
    
        general = @target.xcf_general("Release")
        assert_not_nil(general)
    
        assert_equal("XcodeflowTest",           general.display_name)
        assert_equal("me.klaudz.XcodeflowTest", general.bundle_identifier)
        assert_equal("1.0",                     general.version)
        assert_equal("1",                       general.build)
    
    end

    def test_get_deployment_info

        general = @target.xcf_general("Release")
        assert_not_nil(general)

        assert_equal("13.0",                    general.deployment_target)

    end

    def test_get_app_icons_and_launch_images

        general = @target.xcf_general("Release")
        assert_not_nil(general)

        assert_equal("AppIcon",                 general.app_icons_source)
        assert_equal([File.join(__dir__, "TestProject/XcodeflowTest/Assets.xcassets/AppIcon.appiconset")],
                                                general.app_icons_paths)

    end

end

