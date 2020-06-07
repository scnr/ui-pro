module ExecJS
# Encodes strings as UTF-8
module Encoding
    def encode( string )
        super string
    rescue Encoding::UndefinedConversionError
        string.recode
    end
end
end
