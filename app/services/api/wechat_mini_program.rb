# frozen_string_literal: true

class API::WechatMiniProgram < Grape::API
  namespace :wechat_mini_program do
    desc "获取access token", summary: "获取access token", skip_authentication: true
    get "access_token" do
      error!({ error_message: "401 Unauthorized" }, 401) if request.headers["Api-Authorization-Token"] != Rails.application.credentials.dig(Rails.env.to_sym, BsWechatMiniProgram.client.api_authorization_token_key)

      { access_token: BsWechatMiniProgram.client.get_access_token }
    end
  end
end
