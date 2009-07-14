class UserMailer < ActionMailer::Base
  
  def registration(user)
    recipients user.email
    subject 'installd.com registration'
    from 'registrations@installd.com'
    reply_to 'registrations@installd.com'
    headers({ 'Return-Path' => 'registrations@installd.com' })
    body({ :root_url => root_url(:host => HOST)})
  end
  
  def invitation(user)
    recipients user.email
    subject 'installd.com invitation'
    from 'invitations@installd.com'
    reply_to 'invitations@installd.com'
    headers({ 'Return-Path' => 'invitations@installd.com' })
    body({ :root_url => root_url(:host => HOST), :activation_url => new_activation_url(:code => user.perishable_token, :host => HOST) })
  end
  
  def activation(user)
    recipients user.email
    subject 'installd.com activation'
    from 'activations@installd.com'
    reply_to 'activations@installd.com'
    headers({ 'Return-Path' => 'activations@installd.com' })
    body({ :root_url => root_url(:host => HOST), :downloads_url => downloads_url(:host => HOST) })
  end
  
end
