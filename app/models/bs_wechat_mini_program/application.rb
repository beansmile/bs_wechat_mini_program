module BsWechatMiniProgram
  class Application < ApplicationRecord
    has_many :subscribe_message_templates, class_name: "BsWechatMiniProgram::SubscribeMessageTemplate", dependent: :destroy

    def client
      @client ||= BsWechatMiniProgram::Client.new(appid: appid, secret: secret)
    end
  end
end
