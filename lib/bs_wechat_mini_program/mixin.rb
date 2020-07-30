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

          data = options.slice(:width, :auto_color, :line_color, :is_hyaline)

          data[:page] = options[:page] if BsWechatMiniProgram.set_wxacode_page_option

          response = BsWechatMiniProgram.client.get_unlimited_wxacode(scene, data)

          if response.is_a?(String)
            img_type = data[:is_hyaline] ? "png" : "jpg"
            filename = Digest::MD5.hexdigest(response).concat(".#{img_type}")

            folder = "./tmp/wxacodes"
            temp_file_path = "#{folder}/#{filename}"

            FileUtils.mkdir_p(folder)

            open(temp_file_path, "wb") do |file|
              file << response
            end

            send(column).attach(io: File.open(temp_file_path), filename: filename, content_type: "image/#{img_type}")

            FileUtils.rm_f(temp_file_path)
          else
            raise response["errmsg"]
          end
        end
      end
    end
  end
end
