class System
module Platforms

# @see  https://www.ruby-forum.com/topic/205427
class Windows < Base

    class <<self
        def current?
            ruby_platform =~ /win32|mswin|msys|mingw|cygwin|bccwin|wince|emc/
        end
    end

end
end
end
