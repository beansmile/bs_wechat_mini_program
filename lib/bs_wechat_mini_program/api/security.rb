# frozen_string_literal: true

module BsWechatMiniProgram
  module API
    module Security
      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.imgSecCheck.html
      # 校验一张图片是否含有违法违规内容。
      def img_sec_check(media:)
        body = {
          media: media
        }

        http_post("/wxa/img_sec_check", body: body)
      end

      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
      # 检查一段文本是否含有违法违规内容。
      def msg_sec_check(content:, scene:, openid:)
        body = {
          version: 2,
          content: content,
          openid: openid,
          scene: scene
        }

        http_post("/wxa/msg_sec_check", body: body)
      end
    end
  end
end
