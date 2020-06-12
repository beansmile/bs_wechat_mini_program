# frozen_string_literal: true

module BsWechatMiniProgram
  module API
    module Auth
      # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
      def code_to_session(code)
        body = {
          appid: appid,
          secret: secret,
          js_code: code,
          grant_type: "authorization_code"
        }

        http_get("/sns/jscode2session?#{body.to_query}", {}, false)
      end
    end
  end
end
