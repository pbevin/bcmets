class UserSessionsController < ApplicationController
  # GET /user_sessions/new
  # GET /user_sessions/new.json
  def new
    @user_session = UserSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render json: @user_session }
    end
  end

  # POST /user_sessions
  # POST /user_sessions.json
  def create
    @user_session = UserSession.new(user_session_params)

    respond_to do |format|
      if @user_session.save
        flash[:notice] = 'Logged in successfully.'
        format.html { redirect_back_or_home }
        format.json { render json: { succeeded: true } }
      else
        format.html { render :action => "new" }
        format.json { render json: { succeeded: false, errors: @user_session.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.json
  def destroy
    @user_session = UserSession.find
    @user_session.destroy if @user_session

    flash[:notice] = "Logged out."

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.json  { head :ok }
    end
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password)
  end
end
