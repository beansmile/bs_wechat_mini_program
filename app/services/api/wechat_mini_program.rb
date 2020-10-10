# frozen_string_literal: true

class API::WechatMiniProgram < Grape::API
  namespace :wechat_mini_program do
    helpers do
      def current_wechat_mini_program_client
        @current_wechat_mini_program_client ||= BsWechatMiniProgram.get_client_by_appid.call(params[:appid])
      end
    end

    desc "获取access token", summary: "获取access token", skip_authentication: true
    params do
      requires :appid, desc: "小程序appid"
    end
    get "access_token" do
      error!({ error_message: "401 Unauthorized" }, 401) if request.headers["Api-Authorization-Token"] != Rails.application.credentials.dig(Rails.env.to_sym, BsWechatMiniProgram.client.api_authorization_token_key)

      { access_token: current_wechat_mini_program_client.get_access_token }
    end

    # TODO 需要兼容最新版版
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

    # TODO 需要兼容最新版版
    desc "获取所有模板id"
    get "templates" do
      BsWechatMiniProgram::WechatSubscribe::TEMPLATES
    end

    desc "获取微信用户手机号", detail: <<-NOTES.strip_heredoc
    ```json
    {
      "phoneNumber"=>"1598914xxxx",
      "purePhoneNumber"=>"1598914xxxx",
      "countryCode"=>"86"
    }
    ```
    NOTES
    params do
      requires :appid, desc: "小程序appid"
      requires :encrypted_data, type: String, desc: "完整用户信息的加密数据"
      requires :iv, type: String, desc: "加密算法的初始向量"
    end
    post "authorize_phone" do
      error!("401 Unauthorized", 401) unless current_user
      user_phone_data = current_wechat_mini_program_client.decrypt!(current_user.wechat_mp_session_key, params[:encrypted_data], params[:iv])
      # phoneNumberData:
      # {
      #   "phoneNumber"=>"1598914xxxx",
      #   "purePhoneNumber"=>"1598914xxxx",
      #   "countryCode"=>"86",
      #   "watermark"=>{"timestamp"=>1590565990, "appid"=>"wx93bf3795383fxxxx"}
      # }
      user_phone_data.extract!("watermark")
      present user_phone_data.as_json
    end

    desc "获取小程序分享二维码", detail: <<-NOTES.strip_heredoc
    获取小程序分享二维码
    NOTES
    params do
      requires :appid, desc: "小程序appid"
      requires :path, type: String, desc: "小程序页面"
      requires :scene, type: String, desc: "小程序页面参数"
      optional :width, type: Integer, desc: "二维码宽度"
      optional :is_hyaline, type: Boolean, desc: "是否需要透明底色"
    end
    get "mini_program_qrcode" do
      error!("401 Unauthorized", 401) unless current_user
      scene = params[:scene] + "&tc=#{current_user.tracking_code}"
      content_type "application/octet-stream;charset=ASCII-8BIT"
      env["api.format"] = :binary
      current_wechat_mini_program_client.get_unlimited_wxacode(
        scene, {
          page: params[:path],
          width: params[:width] || 280,
          is_hyaline: params[:is_hyaline] || false
        }
      )
    end
  end
end
