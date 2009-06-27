class UserMailer < ActionMailer::Base
  
  def invitation(user)
    recipients user.email
    subject 'Installd.com invitation'
    from 'invitations@installd.com'
    reply_to 'invitations@installd.com'
    headers({ 'Return-Path' => 'invitations@installd.com' })
    body({ :activation_url => new_activation_url(:code => user.perishable_token, :host => HOST) })
  end
  
end
