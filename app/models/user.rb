# == Schema Information
#
# Table name: users
#
#  user_id                :string(32)       not null, primary key
#  subdomain              :string(50)       not null
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
#  gender                 :string(10)
#  time_since_diagnosis   :string(255)
#  age_range              :string(255)
#  cancer_type            :string(255)
#  city                   :string(50)
#  country                :string(3)
#  mobile_number          :string(20)
#  home_number            :string(20)
#  time_zone              :string(100)
#  is_admin               :boolean          default(FALSE), not null
#  accepted_terms         :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_throttled           :boolean          default(TRUE)
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
    :confirmable, :lockable, :timeoutable,
    :recoverable, :validatable,
    request_keys: [:subdomain]

    ## IDENTIFIER (start) ======================================================
    self.primary_key = 'user_id'
    ## IDENTIFIER (end)

    ## ACCESSORS (start) =======================================================
    attr_accessor :access_token
    ## ACCESSORS (end)

    ## DEFAULTS (start) ========================================================
    before_validation :set_defaults
    ## DEFAULTS (end)

    ## ASSOCIATIONS (start) ====================================================
    belongs_to :tenant, foreign_key: :subdomain
    # has_many :surveys, dependent: :destroy
    # has_many :survey_answers, through: :surveys
    # has_many :user_filters, dependent: :destroy
    # has_many :user_action_steps, dependent: :destroy
    # has_many :action_steps, through: :user_action_steps
    has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
    has_many :logins, dependent: :destroy
    ## ASSOCIATIONS (end)

    ## NESTED ATTRIBUTES (start) ===============================================
    # accepts_nested_attributes_for :survey_answers
    ## NESTED ATTRIBUTES (end)

    ## VALIDATIONS (start) =====================================================
    validates :first_name, presence: true, allow_blank: false
    validates :last_name, presence: true
    validate  :access_token_matches
    validate :password_complexity
    validate :email_format

    def password_complexity
      if password.present? and not password.match(/(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[\W])/)
        errors.add :password, "Passwords must be 8-20 characters long and include 3 of the following: uppercase letters, lowercase letters, numbers and special characters (!, @, #, $, etc.)."
      end
    end

    def email_format
      unless email.include?('@') && email.include?('.')
        errors.add :email, "not a valid email address"
      end
    end
    ## VALIDATIONS (end)

    ## HOOKS (start) =====================================================
#    after_create :build_survey
    ## HOOKS (end)

    ## SCOPES (start) =====================================================
    scope :admins, -> { where(is_admin: true) }
    scope :thrivers, -> { where(is_admin: false) }
    ## SCOPES (end)

    def full_name
      "#{first_name} #{last_name}"
    end

    def new_users_this_month
      User.where('created_at > ?', Time.now.strftime("%Y%m")).count
    end

    def self.search(search, page = 1)
      result = where("is_admin = false and (first_name LIKE :search OR last_name LIKE :search OR email LIKE :search)", search: "%#{search}%")
    end

    def admin?
      is_admin
    end

    def active?
      state == 'active'
    end

    def deactivate
      update_attribute 'state', 'deactivated'
      Track::Deactivate.send_it(self)
    end

    def activate
      update_attribute 'state', 'active'
      Track::Reactivate.send_it(self)
    end

    # def active_for_authentication?
    #   active?
    # end


    private

    # Helper sets all defaults on the current model prior to VALIDATIONS
    def set_defaults
#      self.state ||= 'active'
      self.user_id ||= Track::Util::Uuid.generate
      self.subdomain ||= (Tenant.current ? Tenant.current.subdomain :  Tenant.default_tenant.subdomain)
    end # def set_defaults

    def access_token_matches
      at = self.tenant.access_token
      unless at.blank?
        self.errors.add(:base, "invalid access code") unless self.access_token == at
      end
    end # def access_token_matches

    def passwords_provided
      if self.password.blank? || self.password_confirmation.blank?
        self.errors.add(:password, "password cannot be blank")
      end
    end

    def passwords_match
      unless self.password.blank?
        self.errors.add(:password_confirmation, "passwords do not match") if self.password != self.password_confirmation
      end
    end # def passwords_match

    def self.find_for_authentication(warden_conditions)
      first_subdomain = warden_conditions[:subdomain].split(".").first
      where(:email => warden_conditions[:email], :subdomain => first_subdomain).first
    end

end # class User
