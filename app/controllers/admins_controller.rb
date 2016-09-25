class AdminsController < AdminController

  before_action :set_admin, only: [:reset_password]

    # GET /admins
    # GET /admins.json
    def index
        respond_to do |format|
            format.json { render json: process_search(Admin) }
            format.html # index.html.erb
        end
    end

    # GET /admins/1
    # GET /admins/1.json
    def show
    end

    # GET /admins/new
    def new
        @admin = Admin.new
    end


    # GET /admins/1/edit
    def edit
    end

    def reset_password
      flash[:success] = 'A password reset email has been sent.'
      redirect_to edit_admin_path(@admin)
    end

    # POST /admins
    # POST /admins.json
    def create
        @admin = Admin.new(admin_params)
        respond_to do |format|
            if @admin.save
                format.html { redirect_to edit_admin_path(@admin), notice: 'System Administrator was successfully created.' }
                format.json { render :show, status: :created, location: @admin }
            else
                format.html { render :new }
                format.json { render json: @admin.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /admins/1
    # PATCH/PUT /admins/1.json
    def update
        respond_to do |format|
            if @admin.update(admin_params)
                format.html { redirect_to edit_admin_path(@admin), notice: 'System Administrator was successfully updated.' }
                format.json { render :show, status: :ok, location: @admin }
            else
                format.html { render :edit }
                format.json { render json: @admin.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /admins/1
    # DELETE /admins/1.json
    def destroy
        @admin.destroy
        respond_to do |format|
          format.html { redirect_to admins_url, notice: 'System Administrator was successfully destroyed.' }
          format.json { head :no_content }
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_admin
        @admin = Admin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
        params.require(:admin).permit(Admin.column_names)
    end
end
