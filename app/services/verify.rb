module Verify
  def create_authy_user(country_code, phone_number)
    authy = Authy::API.register_user( cellphone: phone_number,
                                      country_code: country_code)
    @user.update(authy_id: authy.id)
  end

  def send_token
    Authy::API.request_sms(id: @user.authy_id, force: true)
  end
end
