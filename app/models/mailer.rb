class Mailer < ActionMailer::Base
  default :from => "control@ordermanager.biz"


  #def welcome_email(user)
  #  @subject = "Welcome"
  #  @recipients = user.email
  #  @from = "your...@server.com"
  #  @sent_on = Time.now
  #  @body["name"] = user.name
  #  @headers = {}
  #end

  def welcome_email(user)
    @user = user
    @url = "http://my.ordermanager.biz/"
    attachments.inline['om_logo.png'] = File.read(Rails.root.join('app/assets/images/om_logo.png'))
    mail(:to => user.email, :subject => "Welcome to OrderManager.biz")
  end

  def amazon_feed_error(amazon_report)
    @user = amazon_report.channel.admin_user
    @url = "http://my.ordermanager.biz/"
    @amazon_report = amazon_report
    File.open("amazon_feed.xml", 'w') { |f| f.write(@amazon_report.payload) }
    attachments['amazon_feed.xml'] = File.read('amazon_feed.xml')
    attachments.inline['om_logo.png'] = File.read(Rails.root.join('app/assets/images/om_logo.png'))
    mail(:to => user.email, :subject => "Amazon Feed Error Reported")
  end

  def generic_message(subject, body, recipient)
    @user = recipient
    @url = "http://my.ordermanager.biz/"
    @body = body
    mail(:to => @user, :subject => subject)
  end
end