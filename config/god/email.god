God::Contacts::Email.defaults do |d|
  d.from_email = 'god@ordermanager.biz'
  d.from_name = 'OrderManager God'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'stuart'
  c.group = 'developers'
  c.to_email = 'stuart.drennan@gmail.com'
end