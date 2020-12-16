# frozen_string_literal: true

module BsWechatMiniProgram
  class SendSubscribeMessageJob < ApplicationJob
    def perform(account_subscribe:, data:, miniprogram_state: nil, page: nil, lang: nil)
      subscribe_message_template = account_subscribe.subscribe_message_template
      application = subscribe_message_template.application

      miniprogram_state ||= {
        production: "formal",
        staging: "trial",
      }[Rails.env] || "developer"

      response = application.client.send_subscribe_message(
        touser: account_subscribe.openid,
        template_id: subscribe_message_template.pri_tmpl_id,
        data: data,
        miniprogram_state: miniprogram_state,
        page: page,
        lang: lang
      )

      # 0代表成功
      # 43101代表用户拒收该订阅消息
      raise response["errmsg"] unless response["errcode"].in?([0, 43101])

      account_subscribe.destroy
    end
  end
end
