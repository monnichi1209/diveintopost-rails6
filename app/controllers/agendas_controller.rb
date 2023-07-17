class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]
  before_action :authorize_user, only: [:destroy]


  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda') 
    else
      render :new
    end
  end

  def destroy
    @agenda.destroy
    @agenda.team.users.each do |user|
      Rails.logger.info "Sending deletion notification email to #{user.email}..."
      NotificationMailer.agenda_deleted(user, @agenda).deliver_later
      Rails.logger.info "Email sent."
    end
    redirect_to dashboard_url, notice: 'Agenda was successfully destroyed.'
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def authorize_user
    @team = @agenda.team
    redirect_to(dashboard_path, alert: "You are not authorized to delete this agenda.") unless @agenda.user == current_user || @team.owner == current_user
  end
  
  

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
