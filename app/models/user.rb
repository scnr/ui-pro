class User < ActiveRecord::Base
    enum role: [:user, :vip, :admin]
    after_initialize :set_default_role, if: :new_record?

    has_many :sites
    has_and_belongs_to_many :shared_sites, class_name: 'Site',
                            foreign_key: :user_id

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

end
