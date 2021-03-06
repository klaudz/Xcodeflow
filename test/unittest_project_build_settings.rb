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
        assert_equal("$(TEST_ORIGINAL_VALUE)",      build_settings["TEST_EXPANDABLE_VALUE_NONRECURSIVE"])
        assert_equal("$(TEST_EXPANDABLE_VALUE_NONRECURSIVE)", build_settings["TEST_EXPANDABLE_VALUE_RECURSIVE"])

        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_ORIGINAL_VALUE"))
        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_EXPANDABLE_VALUE_NONRECURSIVE"))
        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_EXPANDABLE_VALUE_RECURSIVE"))
    
    end

    def test_get_build_settings_for_expandable_values_of_various_styles
    
        build_settings = @target.xcf_build_settings("Release")
        assert_not_nil(build_settings)
    
        assert_equal("TestValue",                   build_settings["TEST_ORIGINAL_VALUE"])
        assert_equal("$(TEST_ORIGINAL_VALUE)",      build_settings["TEST_EXPANDABLE_VALUE_WITH_PARENTHESES"])
        assert_equal("${TEST_ORIGINAL_VALUE}",      build_settings["TEST_EXPANDABLE_VALUE_WITH_BRACES"])
        assert_equal("$TEST_ORIGINAL_VALUE",        build_settings["TEST_EXPANDABLE_VALUE_WITHOUT_BRACKETS"])

        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_ORIGINAL_VALUE"))
        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_EXPANDABLE_VALUE_WITH_PARENTHESES"))
        assert_equal("TestValue",                   build_settings.resolve_setting("TEST_EXPANDABLE_VALUE_WITH_BRACES"))
        # assert_equal("TestValue",                   build_settings.resolve_setting("TEST_EXPANDABLE_VALUE_WITHOUT_BRACKETS"))     # Failed, Xcodeproj cannot expand this style
    
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

    def test_conditional_build_settings

        build_settings = @target.xcf_build_settings("Release")
        assert_not_nil(build_settings)

        keys = []
        conditions = []
        values = []
        settings = build_settings.each_conditional_setting("TEST_CONDITIONAL_SETTING") { |key, condition, value|
            keys.push(key)
            conditions.push(condition)
            values.push(value)
        }
        assert_equal({
            "TEST_CONDITIONAL_SETTING" => "TestValue",
            "TEST_CONDITIONAL_SETTING[sdk=iphoneos*]" => "TestValue [sdk=iphoneos*]",
            "TEST_CONDITIONAL_SETTING[sdk=iphonesimulator*]" => "TestValue [sdk=iphonesimulator*]",
        }, settings)
        assert_equal([
            "TEST_CONDITIONAL_SETTING",
            "TEST_CONDITIONAL_SETTING[sdk=iphoneos*]",
            "TEST_CONDITIONAL_SETTING[sdk=iphonesimulator*]",
        ], keys)
        assert_equal([
            nil,
            "sdk=iphoneos*",
            "sdk=iphonesimulator*",
        ], conditions)
        assert_equal([
            "TestValue",
            "TestValue [sdk=iphoneos*]",
            "TestValue [sdk=iphonesimulator*]",
        ], values)

    end

end
