module ResourceFeatures
  extend ActiveSupport::Concern

  included do

    # Attempt to fetch the instance of the resource for each action that refers
    # to a single instance.
    before_action :fetch_instance, only: [:edit, :update, :show, :destroy]

  end

  # This method will attempt to fetch a single instance for resource based
  # controllers. It will use the name of the model type defined as a class
  # attribute on the controller if supplied. If not supplied, it will derive
  # it from the name of the controller. The result will be to set an instance
  # variable on the controller by the given model type with the instance found.
  def fetch_instance
    begin
      model_type = (self.model_type.nil? ? controller_name : self.model_type).classify.constantize

      if model_type <= ActiveRecord::Base
        instance = model_type.find(params[:id])
        self.instance_variable_set("@#{model_type.name.underscore}", instance)
      end
    rescue => e
      puts "[ERROR] fetch_instance [#{controller_name}] - #{e.message}".red
    end
  end # def fetch_instance

end # module TenantFeatures
