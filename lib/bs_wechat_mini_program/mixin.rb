# frozen_string_literal: true
module BsWechatMiniProgram
  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      def set_unlimited_wxacode(column, options = {})
        send :after_create_commit do
          BsWechatMiniProgram::SetUnlimitedWxacodeJob.perform_later(self, column)
        end

        send :define_method, "set_#{column}_with_unlimited_wxacode" do
          scene = if options[:scene]
                    if options[:scene].is_a?(String) || options[:scene].is_a?(Symbol)
                      send(options[:scene])
                    else
                      instance_exec(&options[:scene])
                    end
                  else
                    "id=#{id}"
                  end

          data = {}

          data[:page] = options[:page] if BsWechatMiniProgram.set_wxacode_page_option

          response = BsWechatMiniProgram.client.get_unlimited_wxacode(scene, data)

          if response.is_a?(String)
            filename = Digest::MD5.hexdigest(response).concat(".jpg")

            folder = "./tmp/wxacodes"
            temp_file_path = "#{folder}/#{filename}"

            FileUtils.mkdir_p(folder)

            open(temp_file_path, "wb") do |file|
              file << response
            end

            path = BsWechatMiniProgram.oss_adapter.upload_through_path!(temp_file_path)

            FileUtils.rm_f(temp_file_path)

            self.send "#{column}=", path

            save
          else
            raise response["errmsg"]
          end
        end
      end
    end
  end
end
