# Component loading isn't thread-safe so preload everything here.
::ArachniFramework = Arachni::Framework.new
::ArachniFramework.checks.load '*'
::ArachniFramework.reporters.load '*'
::ArachniFramework.plugins.load '*'
