# frozen_string_literal: true

module BsWechatMiniProgram
  module API
    module SubscribeMessage
      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getTemplateList.html
      # 获取当前帐号下的个人模板列表
      def get_template_list
        http_get("/wxaapi/newtmpl/gettemplate")
      end

      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
      # 发送订阅消息
      def send_subscribe_message(openid, template_id, data, options = {})
        body = {
          touser: openid,
          template_id: template_id,
          data: data,
          page: options[:page],
          miniprogram_state: Rails.env.production? ? "formal" : "trial"
        }

        http_post("/cgi-bin/message/subscribe/send", body: body)
      end
    end
  end
end
