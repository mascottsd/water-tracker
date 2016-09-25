class ApplicationController < ActionController::Base
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found
  # rescue_from ::ActionController::RoutingError, with: :error_occurred
  # rescue_from ::NameError, with: :error_occurred
  # Don't rescue from Exception as it will resuce from everything as mentioned here "http://stackoverflow.com/questions/10048173/why-is-it-bad-style-to-rescue-exception-e-in-ruby"
  # rescue_from ::Exception, with: :error_occurred

  protect_from_forgery with: :exception
  around_action :set_time_zone, if: :current_user


  include TenantFeatures

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: ->(exception) { render_error 404, exception }
  end


  def skip_tenancy!
    false
  end

  protected

  def record_not_found(exception)
    render '/errors/error_402'
  end

  def error_occurred(exception)
    render '/errors/error_500'
  end

  private

  def render_error(status, exception)
    Rails.logger.error status.to_s + ' ' + exception.message.to_s
    Rails.logger.error exception.backtrace.join("\n")
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", status: status }
      format.all { render nothing: true, status: status }
    end
  end

  def after_sign_out_path_for(_resource)
    root_path
  end

  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  # generic helper responsibe for performing a full search including support
  # for sorting, paging and filtering.
  def process_search(model, format=:json, options={})
    page = params[:current] || 1
    limit = params[:rowCount] || 10

    query = build_query(model, options[:where])
    total = query.count
    results =  limit == '-1' ? query : query.page(page).per(limit).all.to_a
    Track::Util::Bootgrid.format_response(results, page.to_i, total )
  end # def process_search

  # The query will be dynamically established based on the parameters supplied
  # from the request. This will handle sorting, search, pagination and support
  # for tenancy.
  def build_query(model, where_clause)
    sort = params[:sort] || {}
    criteria = params[:searchPhrase]
    query = (model.respond_to? :search) ? model.send(:search, criteria) : model

    # Auto apply tenancy to queries unless explicitly instructed NOT to do so.
    # Restrict by the current subdomain if the model is related to Tenant.
    unless self.skip_tenancy!
      query = query.where(subdomain: Tenant.current.subdomain) if query.method_defined? :tenant
    end

    query.where(where_clause) if where_clause

    sort.each do |k,v|
      query = query.order(k.to_sym => v)
    end

    query

  end # def build_query


end # class ApplicationController
