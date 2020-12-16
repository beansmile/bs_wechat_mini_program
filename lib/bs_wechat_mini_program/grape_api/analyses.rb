# frozen_string_literal: true

class BsWechatMiniProgram::API::Analyses < Grape::API
  namespace "applications/:appid/analyses" do
    helpers do
      def application
        @application ||= BsWechatMiniProgram::Application.find_by!(appid: params[:appid])
      end
    end

    [
      {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-retain/analysis.getDailyRetain.html
        summary: "获取用户访问小程序日留存",
        action: :getweanalysisappiddailyretaininfo,
        auth_action: :analyse_retain_info
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-retain/analysis.getWeeklyRetain.html
        summary: "获取用户访问小程序周留存",
        action: :getweanalysisappidweeklyretaininfo,
        auth_action: :analyse_retain_info
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-retain/analysis.getMonthlyRetain.html
        summary: "获取用户访问小程序月留存",
        action: :getweanalysisappidmonthlyretaininfo,
        auth_action: :analyse_retain_info
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/analysis.getDailySummary.html
        summary: "获取用户访问小程序数据概况",
        action: :getweanalysisappiddailysummarytrend,
        auth_action: :analyse_summary_and_visit_page
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/analysis.getUserPortrait.html
        summary: "获取小程序用户画像数据",
        action: :getweanalysisappiduserportrait,
        auth_action: :analyse_user_portrait
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-trend/analysis.getDailyVisitTrend.html
        summary: "获取用户访问小程序数据日趋势",
        action: :getweanalysisappiddailyvisittrend,
        auth_action: :analyse_visit_trend
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-trend/analysis.getWeeklyVisitTrend.html
        summary: "获取用户访问小程序数据周趋势",
        action: :getweanalysisappidweeklyvisittrend,
        auth_action: :analyse_visit_trend
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-trend/analysis.getMonthlyVisitTrend.html
        summary: "获取用户访问小程序数据月趋势",
        action: :getweanalysisappidmonthlyvisittrend,
        auth_action: :analyse_visit_trend
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/analysis.getVisitDistribution.html
        summary: "获取小程序访问分布数据",
        action: :getweanalysisappidvisitdistribution,
        auth_action: :analyse_visit_distribution
      }, {
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/analysis.getVisitPage.html
        summary: "获取小程序访问页面数据",
        action: :getweanalysisappidvisitpage,
        auth_action: :analyse_summary_and_visit_page
      }
    ].each do |hash|
      summary = hash[:summary]
      action = hash[:action]
      auth_action = hash[:auth_action]
      desc summary, {
        summary: summary
      }
      params do
        requires :begin_date, type: Date
        requires :end_date, type: Date
      end
      get action do
        error!("401 Unauthorized", 401) unless current_user

        authorize! auth_action, application

        response = application.client.send(action,
          begin_date: params[:begin_date].strftime("%Y%m%d"),
          end_date: params[:end_date].strftime("%Y%m%d")
        )

        error!(response.cn_msg) unless response.success?

        present response
      end
    end
  end
end
