
require 'xcodeproj'

module Xcodeflow

    class Scheme < Xcodeproj::XCScheme

        def initialize(file_path = nil, scheme_name = nil)
            super(file_path)
            @xcf_scheme_name = scheme_name
        end

        attr_reader :xcf_scheme_name

    end

end