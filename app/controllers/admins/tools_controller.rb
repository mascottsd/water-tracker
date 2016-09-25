class Admins::ToolsController < AdminController
  # before_action :redirect_if_no_survey, only: :index

  def console
    respond_to do |format|
      format.html { render :console, notice: 'Be very careful with the console.' }
    end
  end

  def index
    @users = User.where tenant: Tenant.current
    @survey = current_user.current_survey
  end # def index

  private

end # class ToolsController
