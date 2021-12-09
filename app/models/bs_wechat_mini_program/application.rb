module BsWechatMiniProgram
  class Application < ApplicationRecord
    include DataEncryptConcern

    has_many :subscribe_message_templates, class_name: "BsWechatMiniProgram::SubscribeMessageTemplate", dependent: :destroy

    def client
      @client ||= BsWechatMiniProgram::Client.new(appid: appid, secret: secret)
    end

    [:secret].each do |attr|
      define_method attr do
        aes128_decrypt(send("#{attr}_digest"))
      end

      define_method "#{attr}=" do |value|
        send("#{attr}_digest=", aes128_encrypt(value))
      end
    end
  end
end
