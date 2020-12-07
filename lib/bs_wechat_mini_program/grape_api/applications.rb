# frozen_string_literal: true

class BsWechatMiniProgram::API::Applications < Grape::API
  bs_wmp_apis [], { find_by_key: :appid } do
    route_param :appid do
      desc "获取access token", summary: "获取access token"
      params do
        requires :api_authorization_token
      end
      get "access_token" do
        error!({ error_message: "401 Unauthorized" }, 401) if params[:api_authorization_token] != Rails.application.credentials.dig(Rails.env.to_sym, :api_authorization_token)

        { access_token: resource.client.get_access_token }
      end
    end
  end
end
