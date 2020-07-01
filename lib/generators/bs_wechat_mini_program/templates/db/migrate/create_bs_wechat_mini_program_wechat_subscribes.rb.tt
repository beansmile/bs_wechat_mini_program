# frozen_string_literal: true

class CreateBsWechatMiniProgramWechatSubscribes < ActiveRecord::Migration[6.0]
  def change
    create_table :bs_wechat_mini_program_wechat_subscribes do |t|
      t.string :openid
      t.string :event
      t.references :target, polymorphic: true, null: false, index: { name: "index_bs_wechat_mini_program_wechat_subscribe_on_target" }
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
