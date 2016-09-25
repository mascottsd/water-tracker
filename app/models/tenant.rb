# == Schema Information
#
# Table name: tenants
#
#  subdomain            :string(50)       not null, primary key
#  tenant_name          :string(100)      not null
#  custom_domain        :string(100)
#  is_active            :boolean          default(TRUE), not null
#  favicon              :string(255)
#  desktop              :text(65535)
#  login                :text(65535)
#  logo                 :text(65535)
#  privacy_policy       :text(65535)
#  terms_and_conditions :text(65535)
#  footer_text          :string(255)
#  support_number       :string(255)
#  support_link         :string(255)
#  support_email        :string(255)
#  access_token         :string(20)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Tenant < ApplicationRecord
    ## IDENTIFIER (start) ======================================================
    self.primary_key = 'subdomain'
    ## IDENTIFIER (end)

    ## DEFAULTS (start) ========================================================
    before_validation :set_defaults
    ## DEFAULTS (end)

    ## ASSOCIATIONS (start) ====================================================
    has_many :users, foreign_key: 'subdomain'
    ## ASSOCIATIONS (end)

    ## VALIDATIONS (start) =====================================================
    validates :subdomain, uniqueness: true
    validates :subdomain, presence: true
    validates :tenant_name, presence: true
    validates :access_token, length: {maximum: 20}, allow_nil: true
    ## VALIDATIONS (end)

    ## FILE HANDERS (start) ====================================================
    mount_uploader :favicon, ImageUploader
    mount_uploader :desktop, ImageUploader
    mount_uploader :login, ImageUploader
    mount_uploader :logo, ImageUploader
    ## FILE HANDERS (end)

    def self.current=(tenant)
      Thread.current[:tenant] = tenant
    end # def self.current=

    def self.current
      Thread.current[:tenant]
    end # def self.current

    def self.current?
      !self.current.nil?
    end # def self.current

    def self.current_port=(port)
      Thread.current[:tenant_port] = port
    end

    def self.current_port
      Thread.current[:tenant_port]
    end

    def self.current_subdomains=(subdomains)
      Thread.current[:tenant_subdomains] = subdomains.join('.')
    end

    def self.current_subdomains
      Thread.current[:tenant_subdomains]
    end

    def self.default_tenant
      Tenant.where(subdomain: 'app').first
    end # def self.default_tenant

    def self.search(search, page = 1)
      result = where("(tenant_name LIKE :search)", search: "%#{search}%")
    end # def self.search

    def admins
      self.users.admins
    end

    def total_users
      self.users.thrivers.count
    end

    def new_users_this_month
      month_start = "#{Time.now.strftime('%m')}/01/#{Time.now.strftime('%y')}".to_time
      self.users.thrivers.where('created_at > ?', month_start).count
    end

    private

    # Helper sets all defaults on the current model prior to validation.
    def set_defaults
      self.subdomain ||= "app"

      # Default Appearance to those of the Default Tenant
      default_tenant = Tenant.default_tenant
      if default_tenant
	      self.logo = default_tenant.logo if self.logo.file.nil?
	      self.desktop = default_tenant.desktop if self.desktop.file.nil?
	      self.login = default_tenant.login if self.login.file.nil?
	      self.favicon = default_tenant.favicon if self.favicon.file.nil?
	    end
    end # def set_defaults
end # class Tenant
