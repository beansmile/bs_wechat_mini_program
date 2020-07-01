# frozen_string_literal: true

class API::WechatMiniProgram < Grape::API
  namespace :wechat_mini_program do
    desc "获取access token", summary: "获取access token", skip_authentication: true
    get "access_token" do
      error!({ error_message: "401 Unauthorized" }, 401) if request.headers["Api-Authorization-Token"] != Rails.application.credentials.dig(Rails.env.to_sym, BsWechatMiniProgram.client.api_authorization_token_key)

      { access_token: BsWechatMiniProgram.client.get_access_token }
    end

    desc "上报用户订阅模板id"
    params do
      requires :subscribe, type: Array[JSON] do
        requires :target_type, type: String, desc: "相关对象类型"
        requires :target_id, type: Integer, desc: "相关对象对应的ID"
        requires :template_event, type: String, desc: "用户订阅的event", documentation: { param_type: "body" }
      end
    end
    post "subscribe" do
      error!("401 Unauthorized", 401) unless current_user

      ApplicationRecord.transaction do
        params[:subscribe].each do |data|
          BsWechatMiniProgram::WechatSubscribe.create(openid: current_user.wechat_mp_openid, event: data[:template_event], target: data[:target_type].constantize.find(data[:target_id]))
        end
      end

      response_success
    end

    desc "获取所有模板id"
    get "templates" do
      BsWechatMiniProgram::WechatSubscribe::TEMPLATES
    end
  end
end
