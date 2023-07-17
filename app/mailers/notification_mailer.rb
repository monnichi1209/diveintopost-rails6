class NotificationMailer < ApplicationMailer
  def agenda_deleted(user, agenda)
    @user = user
    @agenda = agenda
    mail(to: @user.email, subject: 'An agenda was deleted')
  end
end
