
module Xcodeflow

    class Certificate

        attr_reader :hash

        def initialize(file: nil, data: nil)
            if file
                _initialize_from_file(file)
            elsif data
                _initialize_from_data(data)
            end
            _load_info
        end
        def self.open(file: nil, data: nil)
            self.new(file: file, data: data)
        end

        def _initialize_from_file(file)
        end
        private :_initialize_from_file

        def _initialize_from_data(data)
            @hash = {}
            info = IO.popen('openssl x509 -noout -inform DER -subject -dates -serial', 'r+') { |io|
                io.puts(data)
                io.close_write
                io.read
            }
            info.lines.each { |line|
                line.chomp.split("/").each { |item|
                    components = item.split("=")
                    if components and components.count >= 2
                        @hash[components[0]] = components[1]
                    end
                }
            }
        end
        private :_initialize_from_data

        attr_reader :name, :creation_date, :expiration_date, :serial_number, :sha1

        def _load_info
            @name = @hash["CN"]
            @creation_date = @hash["notBefore"]
            @expiration_date = @hash["notAfter"]
            @serial_number = @hash["serial"]
        end
        private :_load_info

    end
end
