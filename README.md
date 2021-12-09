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
