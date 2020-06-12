module BsWechatMiniProgram
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_index
      template("../templates/bs_wechat_mini_program.rb", "config/initializers/bs_wechat_mini_program.rb")
    end
  end
end
