
require_relative 'certificate'
require 'CFPropertyList'

module Xcodeflow

    class Provision

        attr_reader :plist, :hash
        
        def initialize(path)
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

        attr_reader :app_id_name, :app_id, :team_name, :platforms, :uuid, :creation_date, :expiration_date
        attr_reader :is_xcode_managed
        attr_reader :entitlements
        attr_reader :certificates
        
        def _load_info
            @app_id_name = @hash["AppIDName"]
            @app_id = @hash["Entitlements"]["application-identifier"] if @hash["Entitlements"]
            @team_name = @hash["TeamName"]
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

    end
end
