module BsWechatMiniProgram
  class Application < ApplicationRecord
    encrypts :secret

    has_many :subscribe_message_templates, class_name: "BsWechatMiniProgram::SubscribeMessageTemplate", dependent: :destroy

    def client
      @client ||= BsWechatMiniProgram::Client.new(appid: appid, secret: secret)
    end
  end
end
