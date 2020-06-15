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

```
BsWechatMiniProgram.client.code_to_session(code)
```

```
BsWechatMiniProgram.client.send_subscribe_message(openid, template_id, data, page)
```
