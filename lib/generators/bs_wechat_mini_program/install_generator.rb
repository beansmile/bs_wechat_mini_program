module BsWechatMiniProgram
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_index
      template("../templates/bs_wechat_mini_program.rb", "config/initializers/bs_wechat_mini_program.rb")
    end

    def support_subscribe_message
      template(
        "../templates/db/migrate/create_bs_wechat_mini_program_tables.rb.tt",
        "db/migrate/#{Time.current.strftime("%Y%m%d%H%M%S")}_create_bs_wechat_mini_program_tables.rb"
      )
    end
  end
end
