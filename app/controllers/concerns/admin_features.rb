module AdminFeatures
  extend ActiveSupport::Concern

  included do
    before_action :redirect_tenant
  end

  # Helper determines if the current tenant is setup appropriately. Only
  # requests from app.domain.com should be accepted. If not from app then
  # the user will be redirected to the appropriate host followed by the
  # originating request.
  def redirect_tenant
    subdomains = request.subdomains.dup
    target_subdomain = subdomains.shift

    subdomains.unshift(Track::GlobalConstants::BASE_TENANT)

    redirect_to "http://#{subdomains.join('.')}.#{Track::GlobalConstants::BASE_DOMAIN}#{request.port == 80 ? '' : ':' + request.port.to_s}#{request.path}" unless Track::GlobalConstants::BASE_TENANT == target_subdomain
  end # def identify_tenant

end # module AdminFeatures
