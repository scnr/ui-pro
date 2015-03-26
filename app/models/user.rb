class User < ActiveRecord::Base
    has_many :profiles

    has_many :sites, dependent: :destroy
    has_and_belongs_to_many :shared_sites, class_name: 'Site',
                            foreign_key: :user_id

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :rememberable, :trackable, :registerable,
           :validatable

    def notify_browser( *args )
        WebsocketRails.users[self.id].send_message( *args )
    end

    def to_s
        "#{name} (#{email})"
    end

end
