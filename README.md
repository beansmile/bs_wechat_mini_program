## Setup
Create folder and clone project:

```
mkdir engines && cd engines && git clone https://github.com/beansmile/bs_wechat_mini_program.git
```

Edit your Gemfile:

```
gem "bs_wechat_mini_program", path: "engines/bs_wechat_mini_program"
```

Generate your configuration file:

```
rails g bs_wechat_mini_program:install
```

## Usage
Mount Grape API

```
mount ::API::WechatMiniProgram
```

Get mini program access token

```
BsWechatMiniProgram.client.get_access_token
```

Other mini program API

* [登录 Auth](https://github.com/beansmile/bs_wechat_mini_program/blob/master/lib/bs_wechat_mini_program/api/auth.rb)
* [内容安全 Security](https://github.com/beansmile/bs_wechat_mini_program/blob/master/lib/bs_wechat_mini_program/api/security.rb)
* [订阅消息 SubscribeMessage](https://github.com/beansmile/bs_wechat_mini_program/blob/master/lib/bs_wechat_mini_program/api/subscribe_message.rb)
* [小程序码 Wxacode](https://github.com/beansmile/bs_wechat_mini_program/blob/master/lib/bs_wechat_mini_program/api/wxacode.rb)


### Model methods

set_unlimited_wxacode

生成无限制小程序码并上传到OSS（依赖ActiveStorage)

用法

```
set_unlimited_wxacode :wxacode, page: "page/index/index", scene: -> { "id=#{id}" }
```

第一个参数为has_one_attached对应的属性

第二个参数为Hash类型

* page为小程序码页面（缺省则为主页）
* scene为参数，缺省则为 `id=#{id}`
