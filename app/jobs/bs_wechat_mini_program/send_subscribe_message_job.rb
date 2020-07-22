# frozen_string_literal: true

module BsWechatMiniProgram
  class SendSubscribeMessageJob < ApplicationJob
    def perform(appid, options)
      response = BsWechatMiniProgram::Client.find_by_appid(appid).send_subscribe_message(options[:touser], options[:template_id], options[:data], { page: options[:page] })

      # 0代表成功
      # 43101代表用户拒收该订阅消息
      raise response["errmsg"] unless response["errcode"].in?([0, 43101])
    end
  end
end
