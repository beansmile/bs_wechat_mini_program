# frozen_string_literal: true

BsWechatMiniProgram.configuration do |config|
  # config.get_access_token_api_prefix = "/app_api/v1"

  # page 必须是已经发布的小程序存在的页面（否则报错）
  # 部署正式环境后移除
  # 默认为true
  config.set_wxacode_page_option = Rails.env.production?

  # 使用订阅消息需要设置 redis
  # 需要在 api 实现 current_user
  Sidekiq.redis do |redis|
    config.redis = redis
  end
end
