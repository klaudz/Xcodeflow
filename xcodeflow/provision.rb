
require_relative 'certificate'
require 'CFPropertyList'
require 'fileutils'

module Xcodeflow

    class Provision

        ### Open provision profiles ###

        attr_reader :path, :plist, :hash
        
        def initialize(path)
            @path = path
            @plist = `security cms -D -i "#{path}"`
            status = $?
            unless status.success?
                raise "security: unable to open \"#{path}\" for reading"
            end
            @hash = CFPropertyList.native_types(CFPropertyList::List.new(:data => @plist).value)
            _load_info
            _load_entitlements
            _load_certificates
        end
        def self.open(path)
            self.new(path)
        end

        attr_reader :name, :app_id_name, :app_id, :app_id_prefixes, :app_id_prefix, :team_name, :team_ids, :team_id, :bundle_identifier
        attr_reader :platforms, :uuid, :creation_date, :expiration_date
        attr_reader :is_xcode_managed
        attr_reader :entitlements
        attr_reader :certificates
        
        def _load_info
            @name = @hash["Name"]
            @app_id_name = @hash["AppIDName"]
            @app_id = @hash["Entitlements"]["application-identifier"] if @hash["Entitlements"]
            @app_id_prefixes = @hash["ApplicationIdentifierPrefix"]
            @app_id_prefix = @app_id_prefixes.first if @app_id_prefixes
            @team_name = @hash["TeamName"]
            @team_ids = @hash["TeamIdentifier"]
            @team_id = @team_ids.first if @team_ids
            @bundle_identifier = @app_id.sub(/^\w*\./, "") if @app_id
            @platforms = @hash["Platform"]
            @uuid = @hash["UUID"]
            @creation_date = @hash["CreationDate"]
            @expiration_date = @hash["ExpirationDate"]
            @is_xcode_managed = @hash["IsXcodeManaged"]
        end
        private :_load_info
        
        def _load_entitlements
            @entitlements = @hash["Entitlements"]
        end
        private :_load_entitlements

        def _load_certificates
            @certificates = []
            certificate_data = @hash["DeveloperCertificates"]
            certificate_data.each { |data|
                @certificates.push(Certificate.open(data: data))
            } if certificate_data
        end
        private :_load_certificates

        ### Install provision profiles ###

        def installation_file_name
            raise "unable to get uuid from the provision" if @uuid.nil?
            return @uuid + installation_file_extname
        end

        def installation_file_extname
            file_ext = File.extname(@path)
            return file_ext if @platforms.nil? or @platforms.count == 0
            file_ext_hash = {
                "iOS" => ".mobileprovision",
                "OSX" => ".provisionprofile",
            }
            file_ext = file_ext_hash[@platforms.first]
            return file_ext if file_ext
            file_ext = filefile_ext_hash["iOS"]
            return file_ext
        end

        @@provision_dir_path = File.join(Dir.home, "Library/MobileDevice/Provisioning Profiles")

        def self.install_with_provision(provision)
            FileUtils.mkdir_p(@@provision_dir_path) unless Dir.exist?(@@provision_dir_path)
            file_name = provision.installation_file_name
            file_path = File.join(@@provision_dir_path, file_name)
            if File.file?(file_path)
                puts "\"#{file_name}\" has already been installed"
                return
            end
            FileUtils.cp(provision.path, file_path)
            puts "installed \"#{file_name}\" successfully"
        end

        def self.install_with_path(path)
            provision = self.open(path)
            self.install_with_provision(provision)
        end

    end
end
