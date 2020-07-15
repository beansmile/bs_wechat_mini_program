module BsWechatMiniProgram
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_index
      template("../templates/bs_wechat_mini_program.rb", "config/initializers/bs_wechat_mini_program.rb")
    end

    def support_subscribe_message
      template(
        "../templates/db/migrate/create_bs_wechat_mini_program_wechat_subscribes.rb.tt",
        "db/migrate/#{Time.current.strftime("%Y%m%d%H%M%S")}_create_bs_wechat_mini_program_wechat_subscribes.rb"
      )
      template(
        "../templates/config/subscribe_message_templates.yml",
        "config/subscribe_message_templates.yml"
      )
      say(<<-DOC
        为了支持订阅消息，你需要：
        1. 在 config/bs_wechat_mini_program.rb 配置所用的 redis
        2. 在 config/subscribe_message_templates.yml 需要的模板
        3. 对 current_user 实现 wechat_mp_openid 方法
        为了支持获取手机号，你需要：
        1.对 current_user 实现 wechat_mp_session_key 方法
      DOC
      )
    end
  end
end
