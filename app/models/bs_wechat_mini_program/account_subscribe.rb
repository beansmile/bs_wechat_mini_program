# frozen_string_literal: true

module BsWechatMiniProgram
  class AccountSubscribe < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :target, polymorphic: true
    belongs_to :subscribe_message_template, class_name: "BsWechatMiniProgram::SubscribeMessageTemplate"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def enqueue_send_subscribe_message_job(data:, page: nil, miniprogram_state: nil, lang: nil)
      SendSubscribeMessageJob.perform_later(
        account_subscribe: self,
        page: page,
        data: SubscribeMessageTemplate.data_format(data),
        miniprogram_state: miniprogram_state,
        lang: lang
      )
    end
  end
end
