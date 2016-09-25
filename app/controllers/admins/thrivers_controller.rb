class Admins::ThriversController < AdminController
  before_action :set_user_and_survey, only: [:show, :edit, :score, :complete, :recommend, :restart_survey, :clear_filters, :clear_recommendations, :activate, :deactivat, :resend]
  before_action :set_filters, only: [:show, :edit, :score, :complete, :recommend, :reset]

  def skip_tenancy!
    true
  end

  def model_type
    'User'
  end

  # GET /admins/thrivers
  # GET /admins/thrivers.json
  def index
    respond_to do |format|
      format.json {render json: process_search(User)}
      format.html # index.html.erb
    end
  end # def index


  # GET /admins/thrivers/1 (will redirect to edit)
  # GET /admins/thrivers/1.json
  def show
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @user.id }
      format.json { render json: { rows: (@user.nil? ? [] : [@user.marshall]), status: (@user.nil? ? 404 : 200), total: (@user.nil? ? 0 : 1) } }
    end
  end # def show


  # GET /admins/thrivers/new
  # GET /admins/thrivers/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: { rows: (@user.nil? ? [] : [@user.marshall]), status: (@user.nil? ? 404 : 200), total: (@user.nil? ? 0 : 1) } }
    end
  end # def new


  # POST /admins/thrivers
  # POST /admins/thrivers.json
  def create
    @user = User.new(thriver_params)
    base = 'Failed to save the Thriver. '
    respond_to do |format|
      if @user.save
        flash[:success] = 'The Thriver was successfully created.'
        format.html { redirect_to admins_thriver_url(@user)  }
        format.json { render json: { rows: [@user.marshall], status: 200, total: 1 } }
      else
        flash[:error] = 'An error occured while creating the Thriver.'
        format.html { render action: "new", alert: base + @user.errors.full_messages.to_sentence + "." }
        format.json { render json: { errors: @user.errors, status: :unprocessable_entity } }
      end
    end
  end # def create


  # GET /admins/thrivers/1/edit
  def edit

    @filters = @user.user_filters
    @filter = UserFilter.new
    @parent = @user
    @survey = @user.current_survey

  end # def edit


  # PATCH /admins/thrivers/1
  # PATCH /admins/thrivers/1.json
  def update
    base = 'Failed to save the Thriver. '
    respond_to do |format|
      if @user.update_attributes(thriver_params)
        flash[:success] = 'The thriver was successfully updated.'
        format.html { redirect_to edit_admins_thriver_url(@user) }
        format.json { render json: { rows: [@user.marshall], status: 200, total: 1 } }
      else
        flash[:error] = 'An error occured while updating the Thriver.'
        format.html { render action: "edit", alert: base + @user.errors.full_messages.to_sentence + "." }
        format.json { render json: { errors: @user.errors, status: :unprocessable_entity } }
      end
    end
  end # def update


  # DELETE /admins/thrivers/1
  # DELETE /admins/thrivers/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admins_thrivers_url }
      format.json { render json: { status: 200 } }
    end
  end


  ## CUSTOM ACTIONS (start) ========================================================
  def score
    respond_to do |format|
      if @survey.score
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'Survey was successfully scored.' }
        format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def complete
    respond_to do |format|
      if @survey.complete
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'Survey was successfully completed.' }
        format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def recommend
    respond_to do |format|
      if @survey.recommend
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'Survey was successfully recommended.' }
        format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def restart_survey
    respond_to do |format|
      if @survey.restart_survey
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'Survey was successfully restarted.' }
        format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def clear_filters
    respond_to do |format|
      if @user.user_filters.each { |f| f.destroy }
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'Filters were successfully removed.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def clear_recommendations
    respond_to do |format|
      if @user.user_action_steps.each { |f| f.destroy }
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'Recommendations were successfully removed.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def deactivate
    respond_to do |format|
      if @user.deactivate
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'user was successfully deactivated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    respond_to do |format|
      if @user.activate
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'user was successfully activated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def resend
    respond_to do |format|
      if @user.send_confirmation_instructions
        format.html { redirect_to edit_admins_thriver_path(@user), notice: 'confirmation email was successfully resent.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  ## CUSTOM ACTIONS (end) ========================================================

  private

  # Returns the strong parameters from the request
  def thriver_params
    params.require(:thriver).permit(User.column_names)
  end # def thriver_params

  def set_user_and_survey
    @user = User.find(params[:id])
    @survey = @user.current_survey
  end

  # sets filters instance variables
  def set_filters
    @filters = @user.user_filters
    @filter = UserFilter.new
    @parent = @user
  end


end # class Admins::ThriversController
