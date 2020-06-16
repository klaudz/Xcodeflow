#!/usr/bin/ruby

require_relative '../xcodeflow'
require 'test/unit'

class BuildSettingsTest < Test::Unit::TestCase

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

    def test_get_build_settings_for_original_and_expandable_values
    
        build_settings = @target.xcf_build_settings("Release")
        assert_not_nil(build_settings)
    
        assert_equal("TestValue",                   build_settings["TEST_ORIGINAL_VALUE"])
        assert_equal("$(TEST_ORIGINAL_VALUE)",      build_settings["TEST_EXPANDABLE_VALUE"])
        assert_equal("$(TEST_EXPANDABLE_VALUE)",    build_settings["TEST_RECURSIVE_EXPANDABLE_VALUE"])

        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_ORIGINAL_VALUE"))
        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_EXPANDABLE_VALUE"))
        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_RECURSIVE_EXPANDABLE_VALUE"))
    
    end

    def test_get_build_settings_of_product_information

        build_settings = @target.xcf_build_settings("Release")
        assert_not_nil(build_settings)

        assert_equal(nil,                           build_settings["TARGET_NAME"])
        assert_equal(nil,                           build_settings["EXECUTABLE_NAME"])
        assert_equal(nil,                           build_settings["SRCROOT"])
        assert_equal(nil,                           build_settings["PROJECT_DIR"])

        assert_equal("XcodeflowTest",               build_settings.resolve_setting("TARGET_NAME"))
        assert_equal("XcodeflowTest",               build_settings.resolve_setting("EXECUTABLE_NAME"))
        assert_equal(File.join(__dir__, "TestProject"), build_settings.resolve_setting("SRCROOT"))
        assert_equal(File.join(__dir__, "TestProject"), build_settings.resolve_setting("PROJECT_DIR"))

    end

    def test_get_build_settings_of_expanding_product_information

        build_settings = @target.xcf_build_settings("Release")
        assert_not_nil(build_settings)

        assert_equal("$(TARGET_NAME)",              build_settings["TEST_EXPAND_TARGET_NAME"])
        assert_equal("$(PRODUCT_NAME)",             build_settings["TEST_EXPAND_PRODUCT_NAME"])
        assert_equal("$(EXECUTABLE_NAME)",          build_settings["TEST_EXPAND_EXECUTABLE_NAME"])
        assert_equal("$(SRCROOT)",                  build_settings["TEST_EXPAND_SRCROOT"])
        assert_equal("$(PROJECT_DIR)",              build_settings["TEST_EXPAND_PROJECT_DIR"])

        assert_equal("XcodeflowTest",               build_settings.resolve_setting("TEST_EXPAND_TARGET_NAME"))
        assert_equal("XcodeflowTest",               build_settings.resolve_setting("TEST_EXPAND_PRODUCT_NAME"))
        assert_equal("XcodeflowTest",               build_settings.resolve_setting("TEST_EXPAND_EXECUTABLE_NAME"))
        assert_equal(File.join(__dir__, "TestProject"), build_settings.resolve_setting("TEST_EXPAND_SRCROOT"))
        assert_equal(File.join(__dir__, "TestProject"), build_settings.resolve_setting("TEST_EXPAND_PROJECT_DIR"))

    end

end
