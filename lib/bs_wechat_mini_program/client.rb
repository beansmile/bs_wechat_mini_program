# frozen_string_literal: true

require "httparty"

module BsWechatMiniProgram
  class Client
    include HTTParty
    include BsWechatMiniProgram::API::Auth
    include BsWechatMiniProgram::API::SubscribeMessage
    include BsWechatMiniProgram::API::Wxacode
    include BsWechatMiniProgram::API::Security

    base_uri "https://api.weixin.qq.com"

    @@logger = ::Logger.new("./log/mini_program.log")

    ACCESS_TOKEN_CACHE_KEY = "mini_program_access_token"
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

    attr_accessor :appid, :secret, :get_access_token_api_prefix

    def initialize(appid, secret, options = {})
      @appid = appid
      @secret = secret
      @get_access_token_api_prefix = if options[:get_access_token_api_prefix].present?
                                 options[:get_access_token_api_prefix]
                               else
                                 "/app_api/v1"
                               end
    end

    def host_key
      :host
    end

    def api_authorization_token_key
      :api_authorization_token
    end

    # return token
    def get_access_token
      access_token = Rails.cache.fetch(ACCESS_TOKEN_CACHE_KEY)

      return access_token if access_token

      ENV_FALLBACK_ARRAY.each do |env|
        if Rails.env == env.to_s
          access_token = refresh_access_token

          break
        else
          host = Rails.application.credentials.dig(env, host_key)

          # 未部署的环境暂时不配置host
          next if host.blank?

          resp = http_get("#{host}/#{get_access_token_api_prefix}/wechat_mini_program/access_token", { headers: { "api-authorization-token" => Rails.application.credentials.dig(env, api_authorization_token_key) } }, false)

          next unless access_token = resp["access_token"]

          Rails.cache.write(ACCESS_TOKEN_CACHE_KEY, access_token, expires_in: 5.minutes)

          break
        end
      end

      access_token
    end

    def refresh_access_token
      resp = http_get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret}", {}, false)

      access_token = resp["access_token"]
      Rails.cache.write(ACCESS_TOKEN_CACHE_KEY, access_token, expires_in: 100.minutes)

      access_token
    end

    [:get, :post].each do |method|
      define_method "http_#{method}" do |path, options = {}, need_access_token = true|
        body = (options[:body] || {})
        headers = (options[:headers] || {}).reverse_merge({
          "Content-Type" => "application/json"
        })
        path = "#{path}?access_token=#{get_access_token}" if need_access_token

        uuid = SecureRandom.uuid

        @@logger.debug("request[#{uuid}]: method: #{method}, url: #{path}, body: #{body}, headers: #{headers}")

        response = begin
                     JSON.parse(self.class.send(method, path, body: JSON.pretty_generate(body), headers: headers, timeout: TIMEOUT).body)
                   rescue *HTTP_ERRORS
                     { "errmsg" => "连接超时" }
                   end

        @@logger.debug("response[#{uuid}]: #{response}")

        response
      end
    end
  end
end
