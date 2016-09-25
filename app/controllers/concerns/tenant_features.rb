module TenantFeatures
  extend ActiveSupport::Concern

  included do
    before_action :identify_tenant

    cattr_accessor :skip_tenancy
    cattr_accessor :model_type
  end

  # Helper preceedes all processing of the action and determines the current
  # tenant. All actions are related to a tenant, even those consumer only requests.
  # In those instances the tenant defaults to the iTrack tenant.
  def identify_tenant

    subdomains = request.subdomains.dup
    target_subdomain = subdomains.shift


    if request.domain == Track::GlobalConstants::BASE_DOMAIN
      @current_tenant = Tenant.where(subdomain: target_subdomain).first
    elsif request.host.include?("localhost")
      @current_tenant = Tenant.where(subdomain: "app").first
    else
      @current_tenant = Tenant.where(custom_domain: request.host).first
    end

    if @current_tenant
      Tenant.current = @current_tenant
      Tenant.current_subdomains = request.subdomains
      Tenant.current_port = request.port
      Thread.current[:port] = request.port
    else
      redirect_to "http://#{Track::GlobalConstants::BASE_TENANT}.#{Track::GlobalConstants::BASE_DOMAIN}:#{request.port}"
    end


  end # def identify_tenant

end # module TenantFeatures
