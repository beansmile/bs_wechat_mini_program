# frozen_string_literal: true

class BsWechatMiniProgram::API::SubscribeMessageTemplates < Grape::API
  include Grape::Kaminari

  bs_wmp_apis :index, { belongs_to: :application, belongs_to_find_by_key: :appid } do
    helpers do
      def end_of_association_chain
        @end_of_association_chain ||= parent.subscribe_message_templates
      end
    end

    desc "上报用户订阅模板id"
    params do
      requires :subscribe, type: Array[JSON] do
        requires :target_type, type: String, desc: "相关对象类型"
        requires :target_id, type: Integer, desc: "相关对象对应的ID"
        requires :subscribe_message_template_id, type: Integer, desc: "用户订阅的模板ID", documentation: { param_type: "body" }
      end
    end
    post :subscribe do
      ApplicationRecord.transaction do
        params[:subscribe].each do |data|
          account_subscribe = BsWechatMiniProgram::AccountSubscribe.new(
            openid: current_openid,
            subscribe_message_template_id: data[:subscribe_message_template_id],
            target: data[:target_type].constantize.find(data[:target_id])
          )

          authorize! :create, account_subscribe

          account_subscribe.save!
        end
      end

      response_success
    end
  end
end
