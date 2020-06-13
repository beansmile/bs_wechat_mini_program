# frozen_string_literal: true

module BsWechatMiniProgram
  module API
    module Wxacode
      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.createQRCode.html
      # 获取小程序二维码，适用于需要的码数量较少的业务场景。通过该接口生成的小程序码，永久有效，有数量限制
      def create_qr_code(path, options = {})
        body = {
          path: path
        }.merge(options)

        http_post("/cgi-bin/wxaapp/createwxaqrcode", body: body)
      end

      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.get.html
      # 获取小程序码，适用于需要的码数量较少的业务场景。通过该接口生成的小程序码，永久有效，有数量限制
      def get_wxacode(path, options = {})
        body = {
          path: path
        }.merge(options)

        http_post("/wxa/getwxacode", body: body)
      end

      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.getUnlimited.html
      # 获取小程序码，适用于需要的码数量极多的业务场景。通过该接口生成的小程序码，永久有效，数量暂无限制
      def get_unlimited_wxacode(scene, options = {})
        body = {
          scene: scene
        }.merge(options)

        http_post("/wxa/getwxacodeunlimit", body: body)
      end
    end
  end
end
