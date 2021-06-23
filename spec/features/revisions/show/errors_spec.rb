feature 'Revision errors' do
    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site, user: user }
    let(:profile) { FactoryGirl.create :profile }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:error_messages) do
        <<EOERRORS
2015-09-17 06:59:56 +0300 --------------------------------------------------------------------------------
ENV:
---
XDG_VTNR: '7'
LC_PAPER: en_GR.UTF-8
MANPATH: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro/gems/kramdown-1.4.1/man:/usr/local/qt/doc/man"
LC_ADDRESS: en_GR.UTF-8
KDE_MULTIHEAD: 'false'
XDG_SESSION_ID: c2
rvm_bin_path: "/home/zapotek/.rvm/bin"
SELINUX_INIT: 'YES'
CLUTTER_IM_MODULE: xim
XDG_GREETER_DATA_DIR: "/var/lib/lightdm-data/zapotek"
LC_MONETARY: en_GR.UTF-8
COMP_WORDBREAKS: " \t\n\"'><;|&(:"
SESSION: kde-plasma
GEM_HOME: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro"
GPG_AGENT_INFO: "/tmp/gpg-87yCMK/S.gpg-agent:3125:1"
TERM: xterm
SHELL: "/bin/bash"
IRBRC: "/home/zapotek/.rvm/rubies/ruby-2.2.3/.irbrc"
GTK2_RC_FILES: "/etc/gtk-2.0/gtkrc:/home/zapotek/.gtkrc-2.0:/home/zapotek/.kde/share/config/gtkrc-2.0"
KONSOLE_DBUS_SERVICE: ":1.55936"
KONSOLE_PROFILE_NAME: Shell
GTK_RC_FILES: "/etc/gtk/gtkrc:/home/zapotek/.gtkrc:/home/zapotek/.kde/share/config/gtkrc"
GS_LIB: "/home/zapotek/.fonts"
WINDOWID: '39846700'
LC_NUMERIC: en_GR.UTF-8
UPSTART_SESSION: unix:abstract=/com/ubuntu/upstart-session/1000/3003
QTDIR: "/usr/local/qt"
GNOME_KEYRING_CONTROL: "/run/user/1000/keyring-5PdfcU"
MY_RUBY_HOME: "/home/zapotek/.rvm/rubies/ruby-2.2.3"
SHELL_SESSION_ID: 0c18d86379c24000a8a2785258e90129
GTK_MODULES: overlay-scrollbar
KDE_FULL_SESSION: 'true'
USER: zapotek
LS_COLORS: 'rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
LD_LIBRARY_PATH: "/usr/local/qt/lib:"
LC_TELEPHONE: en_GR.UTF-8
XCURSOR_SIZE: '0'
_system_type: Linux
XDG_SESSION_PATH: "/org/freedesktop/DisplayManager/Session0"
rvm_path: "/home/zapotek/.rvm"
XDG_SEAT_PATH: "/org/freedesktop/DisplayManager/Seat0"
SSH_AUTH_SOCK: "/run/user/1000/keyring-5PdfcU/ssh"
SESSION_MANAGER: local/zonster:@/tmp/.ICE-unix/3302,unix/zonster:/tmp/.ICE-unix/3302
DEFAULTS_PATH: "/usr/share/gconf/kde-plasma.default.path"
XDG_CONFIG_DIRS: "/etc/xdg/xdg-kde-plasma:/usr/share/upstart/xdg:/etc/xdg"
rvm_prefix: "/home/zapotek"
DESKTOP_SESSION: kde-plasma
PATH: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro/bin:/home/zapotek/.rvm/gems/ruby-2.2.3@global/bin:/home/zapotek/.rvm/rubies/ruby-2.2.3/bin:/home/zapotek/.rvm/bin:/usr/local/qt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
QT_QPA_PLATFORMTHEME: appmenu-qt5
QT_IM_MODULE: ibus
LC_IDENTIFICATION: en_GR.UTF-8
JOB: dbus
PWD: "/home/zapotek/workspace/sarosys/scnr/pro"
XMODIFIERS: "@im=ibus"
KONSOLE_DBUS_WINDOW: "/Windows/3"
LANG: en_GR.UTF-8
GNOME_KEYRING_PID: '2988'
KDE_SESSION_UID: '1000'
MANDATORY_PATH: "/usr/share/gconf/kde-plasma.mandatory.path"
GDM_LANG: en_US
LC_MEASUREMENT: en_GR.UTF-8
_system_arch: x86_64
IM_CONFIG_PHASE: '1'
_system_version: '14.04'
KONSOLE_DBUS_SESSION: "/Sessions/96"
GDMSESSION: kde-plasma
rvm_version: 1.26.11 (latest)
SESSIONTYPE: ''
SHLVL: '1'
COLORFGBG: 15;0
XDG_SEAT: seat0
HOME: "/home/zapotek"
KDE_SESSION_VERSION: '4'
LANGUAGE: en:el:en
rvm_ruby_string: ruby-2.2.3
XCURSOR_THEME: oxy-white
UPSTART_INSTANCE: ''
UPSTART_EVENTS: started xsession
LOGNAME: zapotek
GEM_PATH: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro:/home/zapotek/.rvm/gems/ruby-2.2.3@global"
QT4_IM_MODULE: ibus
DBUS_SESSION_BUS_ADDRESS: unix:abstract=/tmp/dbus-SOgYnm9axN
XDG_DATA_DIRS: "/usr/share:/usr/share/kde-plasma:/usr/local/share/:/usr/share/"
GOPATH: "/home/zapotek/workspace/gocode/"
LESSOPEN: "| /usr/bin/lesspipe %s"
INSTANCE: ''
UPSTART_JOB: startkde
TEXTDOMAIN: im-config
rvm_delete_flag: '0'
PROFILEHOME: ''
XDG_RUNTIME_DIR: "/run/user/1000"
DISPLAY: ":0"
QT_PLUGIN_PATH: "/home/zapotek/.kde/lib/kde4/plugins/:/usr/lib/kde4/plugins/"
XDG_CURRENT_DESKTOP: KDE
GTK_IM_MODULE: ibus
RUBY_VERSION: ruby-2.2.3
LESSCLOSE: "/usr/bin/lesspipe %s %s"
LC_TIME: en_GR.UTF-8
PAM_KWALLET_LOGIN: "/tmp//zapotek.socket"
_system_name: Ubuntu
TEXTDOMAINDIR: "/usr/share/locale/"
XAUTHORITY: "/tmp/kde-zapotek/xauth-1000-_0"
LC_NAME: en_GR.UTF-8
_: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro/bin/rails"
_ORIGINAL_GEM_PATH: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro:/home/zapotek/.rvm/gems/ruby-2.2.3@global"
BUNDLE_GEMFILE: "/home/zapotek/workspace/sarosys/scnr/pro/Gemfile"
BUNDLE_BIN_PATH: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro/gems/bundler-1.10.6/bin/bundle"
RUBYOPT: "-rbundler/setup"
RUBYLIB: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro/gems/bundler-1.10.6/lib"
BUNDLE_ORIG_MANPATH: "/home/zapotek/.rvm/gems/ruby-2.3.1@scnr-pro/gems/kramdown-1.4.1/man:/usr/local/qt/doc/man"
RACK_ENV: development
RAILS_ENV: development
--------------------------------------------------------------------------------
OPTIONS:
---
http:
  device_user_agent: Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0
  request_timeout: 10000
  request_redirect_limit: 5
  request_concurrency: 20
  request_queue_size: 100
  request_headers: {}
  response_max_size: 500000
  cookies: {}
audit:
  parameter_values: true
  exclude_vector_patterns: []
  include_vector_patterns: []
  link_templates: []
  links: true
  forms: true
  cookies: true
  ui_forms: true
  ui_inputs: true
input:
  values: {}
  default_values:
    "(?i-mx:name)": scnr_engine_name
    "(?i-mx:user)": scnr_engine_user
    "(?i-mx:usr)": scnr_engine_user
    "(?i-mx:pass)": 5543!%scnr_engine_secret
    "(?i-mx:txt)": scnr_engine_text
    "(?i-mx:num)": '132'
    "(?i-mx:amount)": '100'
    "(?i-mx:mail)": scnr_engine@email.gr
    "(?i-mx:account)": '12'
    "(?i-mx:id)": '1'
  without_defaults: false
  force: false
datastore:
  token: 06a636e8c48bf2b0d4fbf054f4bb7e16
dom:
  wait_for_elements: {}
  pool_size: 6
  job_timeout: 25
  worker_time_to_live: 100
  ignore_images: false
  device_width: 1200
  device_height: 1600
scope:
  redundant_path_patterns: {}
  dom_depth_limit: 5
  exclude_path_patterns: []
  exclude_content_patterns: []
  include_path_patterns: []
  restrict_paths: []
  extend_paths: []
  url_rewrites: {}
session: {}
checks:
- allowed_methods
- backdoors
- backup_directories
- backup_files
- captcha
- code_injection
- code_injection_php_input_wrapper
- code_injection_timing
- common_admin_interfaces
- common_directories
- common_files
- cookie_set_for_parent_domain
- credit_card
- csrf
- cvs_svn_users
- directory_listing
- emails
- file_inclusion
- form_upload
- hsts
- htaccess_limit
- html_objects
- http_only_cookies
- http_put
- insecure_client_access_policy
- insecure_cookies
- insecure_cors_policy
- insecure_cross_domain_policy_access
- insecure_cross_domain_policy_headers
- interesting_responses
- ldap_injection
- localstart_asp
- mixed_resource
- no_sql_injection
- no_sql_injection_differential
- origin_spoof_access_restriction_bypass
- os_cmd_injection
- os_cmd_injection_timing
- password_autocomplete
- path_traversal
- private_ip
- response_splitting
- rfi
- session_fixation
- source_code_disclosure
- sql_injection
- sql_injection_differential
- sql_injection_timing
- ssn
- trainer
- unencrypted_password_forms
- unvalidated_redirect
- unvalidated_redirect_dom
- webdav
- x_frame_options
- xpath_injection
- xss
- xss_dom
- xss_dom_script_context
- xss_event
- xss_path
- xss_script_context
- xss_tag
- xst
- xxe
platforms: []
plugins:
  timing_attacks: {}
  discovery: {}
  autothrottle: {}
no_fingerprinting: false
authorized_by: test@stuff.com
url: http://testphp.vulnweb.com/
--------------------------------------------------------------------------------
#{error_messages_without_env}
EOERRORS
    end

    let(:error_messages_without_env) do
        "[2015-09-17 06:59:56 +0300] My error
[2015-09-17 06:59:56 +0300] My error 2"
    end

    def refresh
        visit errors_site_scan_revision_path( site, scan, revision )
    end

    before do
        revision

        user.sites << site

        login_as user, scope: :user
        refresh
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:errors) { find '#errors' }
    let(:messages) { errors.find 'pre' }

    feature 'when there are errors' do
        before do
            revision.error_messages = error_messages
            revision.save

            refresh
        end

        it 'shows the Error tab' do
            path = errors_site_scan_revision_path( site, scan, revision )

            expect(page.find('#errors-tab')).to have_xpath "a[starts-with(@href, '#{path}?filter')]"
        end

        it 'only shows the error messages' do
            expect(messages.native.text.strip).to eq error_messages_without_env
        end

        feature 'when the scan failed' do
            before do
                revision.failed!
                refresh
            end

            it 'shows the relevant message' do
                expect(errors).to have_content 'may have caused the scan to fail'
            end
        end

        feature 'when the scan succeeded' do
            before do
                revision.completed!
                refresh
            end

            it 'shows the relevant message' do
                expect(errors).to have_content 'the scan was successful'
            end
        end

        feature 'when the scan is active' do
            before do
                revision.scanning!
                refresh
            end

            it 'shows the relevant message' do
                expect(errors).to have_content 'should not affect the rest of the scan'
            end
        end
    end

    feature 'when there are no errors' do
        before do
            revision.error_messages = nil
            revision.save

            refresh
        end

        it 'does not show the Error tab'  do
            expect(page).to_not have_css '#errors-tab'
        end

        it 'redirects to the default action' do
            expect(current_path).to eq issues_site_scan_revision_path( site, scan, revision )
        end
    end

end
