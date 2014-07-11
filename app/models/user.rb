class User < ActiveRecord::Base
    enum role: [:user, :vip, :admin]
    after_initialize :set_default_role, if: :new_record?

    has_and_belongs_to_many :sites

    def set_default_role
        self.role ||= :user
    end

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    def has_site?( site )
        sites.select(:id).where( site.id ).any?
    end

    def to_s
        "#{name} (#{email})"
    end

end
