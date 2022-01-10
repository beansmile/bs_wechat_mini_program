# frozen_string_literal: true

require "httparty"
require "openssl"
require "base64"
require "json"

module BsWechatMiniProgram
  class Client
    include HTTParty
    include BsWechatMiniProgram::API::Auth
    include BsWechatMiniProgram::API::SubscribeMessage
    include BsWechatMiniProgram::API::Wxacode
    include BsWechatMiniProgram::API::Security
    include BsWechatMiniProgram::API::Analysis
    include BsWechatMiniProgram::API::Business

    base_uri "https://api.weixin.qq.com"

    @@logger = ::Logger.new("./log/wechat_mini_program.log")

    ENV_FALLBACK_ARRAY = [:production, :staging, :development]
    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error
    ]
    TIMEOUT = 5

    attr_accessor :appid, :secret

    def initialize(appid:, secret:)
      @appid = appid
      @secret = secret
    end

    def decrypt!(session_key:, encrypted_data:, iv:)
      begin
        cipher = OpenSSL::Cipher::AES.new 128, :CBC
        cipher.decrypt
        cipher.padding = 0
        cipher.key = Base64.decode64(session_key)
        cipher.iv  = Base64.decode64(iv)
        data = cipher.update(Base64.decode64(encrypted_data)) << cipher.final
        result = JSON.parse data[0...-data.last.ord]
      rescue StandardError => e
        @@logger.debug("[UserData] decrypt error: #{e.message}")
        raise "微信解析数据错误"
      end

      if result.dig("watermark", "appid") != appid
        @@logger.debug("[UserData] decrypt error: #{result}")
        raise "微信解析数据错误"
      end

      result
    end

    def access_token_cache_key
      @access_token_cache_key ||= "#{appid}:wechat_mini_program_access_token"
    end

    # return token
    def get_access_token
      access_token = Rails.cache.fetch(access_token_cache_key)

      return access_token if access_token

      ENV_FALLBACK_ARRAY.each do |env|
        if Rails.env == env.to_s
          access_token = refresh_access_token

          break
        else
          host = Rails.application.credentials.dig(env, :host)

          # 未部署的环境暂时不配置host
          next if host.blank?

          resp = self.class.get("#{host}/wechat_mini_program_api/applications/#{appid}/access_token", {
            body: { api_authorization_token: Rails.application.credentials.dig(env, :api_authorization_token) }
          })

          next unless access_token = resp["access_token"]

          Rails.cache.write(access_token_cache_key, access_token, expires_in: 5.minutes)

          break
        end
      end

      access_token
    end

    def refresh_access_token
      resp = http_get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret}", {}, need_access_token: false)

      access_token = resp["access_token"]
      Rails.cache.write(access_token_cache_key, access_token, expires_in: 100.minutes)

      access_token
    end

    [:get, :post].each do |method|
      define_method "http_#{method}" do |path, options = {}, other_config = {}|
        body = (options[:body] || {}).select { |_, v| !v.nil? }
        headers = (options[:headers] || {}).reverse_merge({
          "Content-Type" => "application/json",
          "Accept-Encoding" => "*"
        })
        other_config = other_config.reverse_merge!({ need_access_token: true, format_data: true })
        path = "#{path}?access_token=#{get_access_token}" if other_config[:need_access_token]

        uuid = SecureRandom.uuid

        @@logger.debug("request[#{uuid}]: method: #{method}, url: #{path}, body: #{body}, headers: #{headers}")

        response = begin
                     resp = self.class.send(method, path, body: JSON.pretty_generate(body), headers: headers, timeout: TIMEOUT)

                     if resp.success?
                       JSON.parse(resp.body)
                     else
                       { "errmsg" => "请求错误（code: #{resp.code})" }
                     end
                   rescue JSON::ParserError
                     resp.body
                   rescue *HTTP_ERRORS
                     { "errmsg" => "连接超时" }
                   end

        @@logger.debug("response[#{uuid}]: #{response}")
        other_config[:format_data] ? BsWechatMiniProgram::Result.new(response) : response
      end
    end
  end
end
