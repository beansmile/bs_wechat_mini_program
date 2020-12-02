# frozen_string_literal: true

class BsWechatMiniProgram::API::Default < Grape::API
  helpers do
    def current_application_client
      @current_application ||= BsWechatMiniProgram::Application.find_by!(appid: params[:appid]).client
    end
  end

  route_param :appid do
    desc "获取access token", summary: "获取access token", skip_authentication: true
    params do
      requires :api_authorization_token
    end
    get "access_token" do
      error!({ error_message: "401 Unauthorized" }, 401) if params[:api_authorization_token] != Rails.application.credentials.dig(Rails.env.to_sym, :api_authorization_token)

      { access_token: current_application_client.get_access_token }
    end

    # TODO 需要重写，兼容多个小程序的场景
    # desc "上报用户订阅模板id"
    # params do
    # requires :subscribe, type: Array[JSON] do
    # requires :target_type, type: String, desc: "相关对象类型"
    # requires :target_id, type: Integer, desc: "相关对象对应的ID"
    # requires :template_event, type: String, desc: "用户订阅的event", documentation: { param_type: "body" }
    # end
    # end
    # post "subscribe" do
    # error!("401 Unauthorized", 401) unless current_user

    # ApplicationRecord.transaction do
    # params[:subscribe].each do |data|
    # BsWechatMiniProgram::WechatSubscribe.create(openid: current_user.wechat_mp_openid, event: data[:template_event], target: data[:target_type].constantize.find(data[:target_id]))
    # end
    # end

    # response_success
    # end

    # TODO 需要重写，兼容多个小程序的场景
    # desc "获取所有模板id"
    # get "templates" do
    # BsWechatMiniProgram::WechatSubscribe::TEMPLATES
    # end

    # desc "获取微信用户手机号", detail: <<-NOTES.strip_heredoc
    # ```json
      # {
        # "phoneNumber"=>"1598914xxxx",
        # "purePhoneNumber"=>"1598914xxxx",
        # "countryCode"=>"86"
      # }
    # ```
    # NOTES
    # params do
      # requires :encrypted_data, type: String, desc: "完整用户信息的加密数据"
      # requires :iv, type: String, desc: "加密算法的初始向量"
    # end
    # post "authorize_phone" do
      # error!("401 Unauthorized", 401) unless current_user
      # user_phone_data = current_application_client.decrypt!(session_key: current_user.wechat_mp_session_key, encrypted_data: params[:encrypted_data], iv: params[:iv])
      # # phoneNumberData:
      # # {
      # #   "phoneNumber"=>"1598914xxxx",
      # #   "purePhoneNumber"=>"1598914xxxx",
      # #   "countryCode"=>"86",
      # #   "watermark"=>{"timestamp"=>1590565990, "appid"=>"wx93bf3795383fxxxx"}
      # # }
      # user_phone_data.extract!("watermark")
      # present user_phone_data.as_json
    # end

    # TODO 需要重写，兼容多个小程序的场景
    # desc "获取小程序分享二维码", detail: <<-NOTES.strip_heredoc
    # 获取小程序分享二维码
    # NOTES
    # params do
    # requires :path, type: String, desc: "小程序页面, 开头不能带'/'符号"
    # requires :scene, type: String, desc: "小程序页面参数"
    # optional :width, type: Integer, desc: "二维码宽度"
    # optional :auto_color, type: Grape::API::Boolean, desc: "自动配置线条颜色"
    # optional :line_color, type: JSON, desc: "auto_color 为 false 时生效，使用 rgb 设置颜色"
    # optional :is_hyaline, type: Grape::API::Boolean, default: true, desc: "是否需要透明底色"
    # optional :binary, type: Grape::API::Boolean, desc: "是获取binary还是返回图片路径"
    # end
    # get "getwxacodeunlimit" do
    # error!("401 Unauthorized", 401) unless current_user

    # scene = params[:scene] + "&tc=#{current_user.tracking_code}"
    # content_type "application/octet-stream;charset=ASCII-8BIT"
    # env["api.format"] = :binary
    # BsWechatMiniProgram.client.get_unlimited_wxacode(
    # scene, {
    # page: params[:path],
    # width: params[:width] || 280,
    # is_hyaline: params[:is_hyaline] || false
    # }
    # )
    # end
  end
end
