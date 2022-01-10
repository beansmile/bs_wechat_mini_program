module BsWechatMiniProgram
  module API
    module Business
      def getuserphonenumber(code:)
        http_post("/wxa/business/getuserphonenumber", { body: {
          code: code
        } })
      end
    end
  end
end
