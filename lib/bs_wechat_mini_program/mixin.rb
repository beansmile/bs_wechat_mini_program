# frozen_string_literal: true
module BsWechatMiniProgram
  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      BsWechatMiniProgram::Client.name_clients.keys.each do |name|
        # set_client_unlimited_wxcode
        # set_staff_unlimited_wxcode
        define_method "set_#{name}_unlimited_wxacode" do |column, options = {}|
          send :after_create_commit do
            BsWechatMiniProgram::SetUnlimitedWxacodeJob.perform_later(self, name, column)
          end

          send :define_method, "set_#{column}_with_#{name}_unlimited_wxacode" do
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

            response = BsWechatMiniProgram::Client.find_by_name(name).get_unlimited_wxacode(scene, data)

            if response.is_a?(String)
              filename = Digest::MD5.hexdigest(response).concat(".jpg")

              folder = "./tmp/wxacodes"
              temp_file_path = "#{folder}/#{filename}"

              FileUtils.mkdir_p(folder)

              open(temp_file_path, "wb") do |file|
                file << response
              end

              send(column).attach(io: File.open(temp_file_path), filename: filename, content_type: "image/jpg")

              FileUtils.rm_f(temp_file_path)
            else
              raise response["errmsg"]
            end
          end
        end
      end
    end
  end
end
