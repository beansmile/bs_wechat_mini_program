module BsWechatMiniProgram
  class Application < ApplicationRecord
    def client
      @client ||= BsWechatMiniProgram::Client.new(appid: appid, secret: secret)
    end
  end
end
