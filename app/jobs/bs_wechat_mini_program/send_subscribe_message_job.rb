# frozen_string_literal: true

module BsWechatMiniProgram
  class SendSubscribeMessageJob < ApplicationJob
    def perform(options)
      response = BsWechatMiniProgram.client.send_subscribe_message(options[:openid], options[:template_id], options[:data], { page: options[:page] })

      # 0代表成功
      # 43101代表用户拒收该订阅消息
      raise response["errmsg"] unless response["errcode"].in?([0, 43101])
    end
  end
end
