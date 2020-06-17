#!/usr/bin/ruby

require_relative '../xcodeflow'
require 'test/unit'

class InfoTest < Test::Unit::TestCase

    @project_path
    @project

    def setup
        @project_path = File.join(__dir__, "TestProject/XcodeflowTest.xcodeproj")
        @project = Xcodeflow::Project.open(@project_path)
    end

    def test_get_info

        target = @project.targets.select { |target|
            target.name == "XcodeflowTest"
        }.first
        assert_not_nil(target)
    
        info = target.xcf_info("Release")
        assert_not_nil(info)
    
        assert_equal("XcodeflowTest/Info.plist",        info.info_plist_file)

        assert_equal(nil,                               info["CFBundleDisplayName"])
        assert_equal("$(PRODUCT_NAME)",                 info["CFBundleName"])
        assert_equal("$(PRODUCT_BUNDLE_IDENTIFIER)",    info["CFBundleIdentifier"])
        assert_equal("1.0",                             info["CFBundleShortVersionString"])
        assert_equal("1",                               info["CFBundleVersion"])
        assert_equal("$(EXECUTABLE_NAME)",              info["CFBundleExecutable"])

        assert_equal(nil,                               info.resolve_property("CFBundleDisplayName"))
        assert_equal("XcodeflowTest",                   info.resolve_property("CFBundleName"))
        assert_equal("me.klaudz.XcodeflowTest",         info.resolve_property("CFBundleIdentifier"))
        assert_equal("1.0",                             info.resolve_property("CFBundleShortVersionString"))
        assert_equal("1",                               info.resolve_property("CFBundleVersion"))
        assert_equal("XcodeflowTest",                   info.resolve_property("CFBundleExecutable"))
    
    end

end
