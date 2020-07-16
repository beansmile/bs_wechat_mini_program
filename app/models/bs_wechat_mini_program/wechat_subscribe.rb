module BsWechatMiniProgram
  class WechatSubscribe < ApplicationRecord
    BsWechatMiniProgram::Client.name_clients.keys.each do |name|
      const_set("#{name.upcase}_TEMPLATES", YAML.load(File.read("#{Rails.root}/config/#{name}_subscribe_message_templates.yml"))[Rails.env])
    end

    belongs_to :target, polymorphic: true

    enum status: { pending: 0, completed: 1 }

    attr_accessor :page, :extra

    def self.data_format(data)
      data.inject({}) do |hash, h|
        type = h[0].to_s
        value = h[1][:value]

        if value.present?
          value = if type.start_with?("thing", "name")
                    # name 10个以内纯汉字或20个以内纯字母或符号
                    value.truncate(20)
                  elsif type.start_with?("letter", "character_string")
                    value.truncate(32)
                  elsif type.start_with?("symbol")
                    value.truncate(5)
                  elsif type.start_with?("phone_number")
                    value.truncate(17)
                  elsif type.start_with?("car_number")
                    value.truncate(8)
                  elsif type.start_with?("phrase")
                    value.truncate(5)
                  else
                    value
                  end
        end

        hash[type] = { value: value }

        hash
      end
    end

    BsWechatMiniProgram::Client.name_clients.values.each do |client|
      # send_client_template_later
      # send_staff_template_later
      define_singleton_method "send_#{client.name}_template_later" do |openid, event, target, page = nil, extra = {}|
        wechat_subscribe = pending.find_by(appid: client.appid, openid: openid, event: event, target: target)

        return unless wechat_subscribe

        wechat_subscribe.page = page
        wechat_subscribe.extra = extra

        wechat_subscribe.send("send_#{client.name}_template_later")
      end

      define_method "#{client.name}_template_id" do
        self.class.const_get("#{client.name.upcase}_TEMPLATES")[event.to_s]
      end

      define_method "#{client.name}_template_message_params" do
        data = if extra.present?
                 self.class.data_format(target.send("#{event}_data", extra.deep_symbolize_keys))
               else
                 self.class.data_format(target.send("#{event}_data"))
               end

        {
          touser: openid,
          template_id: send("#{client.name}_template_id"),
          page: page,
          data: data
        }
      end

      define_method "send_#{client.name}_template_later" do
        return if Rails.env.test?

        transaction do
          BsWechatMiniProgram.redis.multi do
            completed!
            SendSubscribeMessageJob.perform_later(client.appid, send("#{client.name}_template_message_params"))
          end
        end
      end
    end
  end
end
