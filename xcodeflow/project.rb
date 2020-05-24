
require 'xcodeproj'
require_relative 'project/general'
require_relative 'project/signing'
require_relative 'xcodeproj-extensions/native_target.rb'

module Xcodeflow

    class Project < Xcodeproj::Project
    end

end
