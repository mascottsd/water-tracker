# == Schema Information
#
# Table name: admins
#
#  admin_id               :string(32)       not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  first_name             :string(50)       not null
#  last_name              :string(50)       not null
#  city                   :string(50)
#  country                :string(3)
#  mobile_number          :string(20)
#  home_number            :string(20)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Admin < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
    #:recoverable, :rememberable, :trackable, :validatable#,
    #:confirmable, :lockable, :timeoutable
    devise :database_authenticatable, :recoverable, :rememberable,
               :confirmable, :lockable, :timeoutable

    ## IDENTIFIER (start) ======================================================
    self.primary_key = 'admin_id'
    ## IDENTIFIER (end)

    ## DEFAULTS (start) ========================================================
    before_validation :set_defaults
    ## DEFAULTS (end)

    ## ASSOCIATIONS (start) ====================================================
    ## ASSOCIATIONS (end)

    ## VALIDATIONS (start) =====================================================
    validates :first_name, presence: true, allow_blank: false
    validates :last_name, presence: true
    validates :email, uniqueness: true
    ## VALIDATIONS (end)

    def full_name
        "#{first_name} #{last_name}"
    end

    def self.search(search, page = 1)
      result = where("(first_name LIKE :search OR last_name LIKE :search OR email LIKE :search)", search: "%#{search}%")
    end

    private

    # Helper sets all defaults on the current model prior to validation.
    def set_defaults
        # user_id
        self.admin_id ||= Track::Util::Uuid.generate
    end # def set_defaults
end
