# frozen_string_literal: true

BsWechatMiniProgram.configuration do |config|
  wechat_config = Rails.application.credentials.dig(Rails.env.to_sym, :wechat)

  config.appid = wechat_config[:appid]
  config.secret = wechat_config[:secret]

  # config.get_access_token_api_prefix = "/app_api/v1"

  # page 必须是已经发布的小程序存在的页面（否则报错）
  # 部署正式环境后移除
  # 默认为true
  config.set_wxacode_page_option = Rails.env.production?

  # 如需生成小程序码或二维码并上传到OSS，则需要配置oss_adapter和oss_config
  # 支持
  # * BsWechatMiniProgram::OssAdapter::Aws
  #
  # ### 对象存储
  #
  # oss_config = Rails.application.credentials.dig(Rails.env.to_sym, :oss_config)
  #
  # AWS S3
  #
  # BsWechatMiniProgram::OssAdapter::Aws
  #
  # 腾讯云COS
  #
  # BsWechatMiniProgram::OssAdapter::Tencent
  #
  # config.oss_adapter = BsWechatMiniProgram::OssAdapter::Aws
  #
  # config.oss_config = {
  #   access_key_id: oss_config[:access_key_id],
  #   secret_access_key: oss_config[:secret_access_key],
  #   region: oss_config[:region],
  #   bucket: oss_config[:oss_bucket]
  # }
end
