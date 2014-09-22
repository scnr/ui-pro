class User < ActiveRecord::Base
    enum role: [:user, :vip, :admin]
    after_initialize :set_default_role, if: :new_record?

    has_one :profile_override, as: :profile_overridable, dependent: :destroy,
            autosave: true
    accepts_nested_attributes_for :profile_override

    has_many :profiles

    has_many :sites, dependent: :destroy
    has_and_belongs_to_many :shared_sites, class_name: 'Site',
                            foreign_key: :user_id

    after_initialize :prepare_profile_override

    validates_associated :profile_override

    def set_default_role
        self.role ||= :user
    end

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    def has_shared_site?( site )
        shared_sites.select(:id).where( site.id ).any?
    end

    def notify_browser( *args )
        WebsocketRails.users[self.id].send_message( *args )
    end

    def to_s
        "#{name} (#{email})"
    end

    private

    def prepare_profile_override
        build_profile_override if !profile_override
        true
    end

end
