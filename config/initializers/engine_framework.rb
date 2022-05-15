EXCLUDE_PLUGINS = [
    :beep_notify,
    :cookie_collector,
    :email_notify,
    :script,
    :vector_feed,
    :vector_collector,
    :waf_detector,
    :autologin,
    :login_script,
    :form_dicattack,
    :http_dicattack,
    :exec
]

DEFAULT_PLUGINS = [
    :timing_attacks,
    :discovery,
    :autothrottle
]

EXCLUDE_REPORTERS = [
    :txt,
    :stdout
]

# Component loading isn't thread-safe so preload everything here.
::SCNREngineFramework = SCNR::Engine::Framework.unsafe
::SCNREngineFramework.checks.load '*'
::SCNREngineFramework.reporters.load ['*'] + EXCLUDE_REPORTERS.map { |p| "-#{p}" }
::SCNREngineFramework.plugins.load ['*', '-default*'] + EXCLUDE_PLUGINS.map { |p| "-#{p}" }
