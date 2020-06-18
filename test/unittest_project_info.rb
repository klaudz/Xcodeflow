#!/usr/bin/ruby

require_relative '../xcodeflow'
require 'test/unit'

class InfoTest < Test::Unit::TestCase

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

    def test_get_info

        info = @target.xcf_info("Release")
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

    def test_get_info_for_original_and_expandable_values

        info = @target.xcf_info("Release")
        assert_not_nil(info)

        assert_equal("TestValue",                       info["XCFTestOriginalValue"])
        assert_equal("$(TEST_ORIGINAL_VALUE)",          info["XCFTestExpandableValueNonrecursive"])
        assert_equal("$(TEST_EXPANDABLE_VALUE_NONRECURSIVE)", info["XCFTestExpandableValueRecursive"])
        
        assert_equal("TestValue",                       info.resolve_property("XCFTestOriginalValue"))
        assert_equal("TestValue",                       info.resolve_property("XCFTestExpandableValueNonrecursive"))
        assert_equal("TestValue",                       info.resolve_property("XCFTestExpandableValueRecursive"))

    end

    def test_get_info_for_expandable_values_of_various_styles

        info = @target.xcf_info("Release")
        assert_not_nil(info)

        assert_equal("TestValue",                       info["XCFTestOriginalValue"])
        assert_equal("$(TEST_ORIGINAL_VALUE)",          info["XCFTestExpandableValueWithParentheses"])
        assert_equal("${TEST_ORIGINAL_VALUE}",          info["XCFTestExpandableValueWithBraces"])
        assert_equal("$TEST_ORIGINAL_VALUE",            info["XCFTestExpandableValueWithoutBrackets"])
        
        assert_equal("TestValue",                       info.resolve_property("XCFTestOriginalValue"))
        assert_equal("TestValue",                       info.resolve_property("XCFTestExpandableValueWithParentheses"))
        assert_equal("TestValue",                       info.resolve_property("XCFTestExpandableValueWithBraces"))
        assert_equal("TestValue",                       info.resolve_property("XCFTestExpandableValueWithoutBrackets"))

    end

    def test_get_info_for_expandable_values_in_combination

        info = @target.xcf_info("Release")
        assert_not_nil(info)

        assert_equal("TestValue_$(TEST_ORIGINAL_VALUE)_$(TEST_EXPANDABLE_VALUE_NONRECURSIVE)",
                                                        info["XCFTestExpandableValueCombination"])
        
        assert_equal("TestValue_TestValue_TestValue",   info.resolve_property("XCFTestExpandableValueCombination"))

    end

end
