module BsWechatMiniProgram
  class WechatSubscribe < ApplicationRecord
    TEMPLATES = YAML.load(File.read("#{Rails.root}/config/subscribe_message_templates.yml"))[Rails.env]

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

    def self.send_template_later(openid, event, target, page = nil, extra = {})
      wechat_subscribe = pending.find_by(openid: openid, event: event, target: target)

      return unless wechat_subscribe

      wechat_subscribe.page = page
      wechat_subscribe.extra = extra

      wechat_subscribe.send_template_later
    end

    def template_id
      TEMPLATES[event.to_s]
    end

    def template_message_params
      {
        touser: openid,
        template_id: template_id,
        page: page,
        data: self.class.data_format(target.send("#{event}_data"))
      }
    end

    def send_template_later
      return if Rails.env.test?

      transaction do
        BsWechatMiniProgram.redis.multi do
          completed!
          WechatTemplateMessageJob.perform_later(template_message_params)
        end
      end
    end
  end
end
