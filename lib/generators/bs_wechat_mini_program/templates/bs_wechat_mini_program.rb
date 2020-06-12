# frozen_string_literal: true

BsWechatMiniProgram.configuration do |config|
  wechat_config = Rails.application.credentials.dig(Rails.env.to_sym, :wechat)

  config.appid = wechat_config[:appid]
  config.secret = wechat_config[:secret]

  # config.get_access_token_api_prefix = "/app_api/v1"
end
