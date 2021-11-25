# frozen_string_literal: true

module BsWechatMiniProgram
  module API
    module Wxacode
      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.createQRCode.html
      # 获取小程序二维码，适用于需要的码数量较少的业务场景。通过该接口生成的小程序码，永久有效，有数量限制
      def createwxaqrcode(path:, width: nil)
        http_post("/cgi-bin/wxaapp/createwxaqrcode", { body: {
          path: path,
          width: width
        } }, { format_data: false })
      end

      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.get.html
      # 获取小程序码，适用于需要的码数量较少的业务场景。通过该接口生成的小程序码，永久有效，有数量限制
      def getwxacode(path:, width: nil, auto_color: nil, line_color: nil, is_hyaline: nil)
        http_post("/wxa/getwxacode", { body: {
          page: page,
          width: width,
          auto_color: auto_color,
          line_color: line_color,
          is_hyaline: is_hyaline
        } }, { format_data: false })
      end


      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.getUnlimited.html
      # 获取小程序码，适用于需要的码数量极多的业务场景。通过该接口生成的小程序码，永久有效，数量暂无限制
      def getwxacodeunlimit(scene:, page: nil, width: nil, auto_color: nil, line_color: nil, is_hyaline: nil, env_version: nil)

        http_post("/wxa/getwxacodeunlimit", { body: {
          scene: scene,
          page: page,
          width: width,
          auto_color: auto_color,
          line_color: line_color,
          is_hyaline: is_hyaline,
          env_version: env_version
        } }, { format_data: false })
      end
    end
  end
end
