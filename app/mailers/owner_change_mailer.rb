class OwnerChangeMailer < ApplicationMailer
  def notify_new_owner(user)
    @user = user
    mail(to: @user.email, subject: 'You are now the team owner')
  end
end
