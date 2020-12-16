# frozen_string_literal: true

module BsWechatMiniProgram
  class SubscribeMessageTemplate < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :application, class_name: "BsWechatMiniProgram::Application"
    has_many :account_subscribes, class_name: "BsWechatMiniProgram::SubscribeMessageTemplate", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods
    def self.send_message_later(openid:, target:, event:, data:, page: nil, miniprogram_state: nil, lang: nil)
      account_subscribe = AccountSubscribe.joins(:subscribe_message_template).find_by(openid: openid, target: target, bs_wechat_mini_program_subscribe_message_templates: { event: event })

      return unless account_subscribe

      account_subscribe.enqueue_send_subscribe_message_job(page: page, data: data, miniprogram_state: miniprogram_state, lang: lang)
    end

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
    # instance methods
  end
end
