# cocoapods-cache-proxy

pod依赖私服缓存服务, [服务端](https://github.com/0x1306a94/cocoapods-cache-proxy-server), 目前仅支持依赖库的源是 `git + tag` 方式


## Installation

```shell
$ gem install cocoapods-cache-proxy
```

## Usage

```shell
$ pod cache proxy add NAME http://domain/cocoapods/proxy/repos # USER PASSWORD (USER PASSWORD 为 http basic auth user and password)
```

## Private library authorization configuration

```shell
$ pod cache proxy auth add DOMAIN TOKEN
```

* GitHub Sample	
	* open https://github.com/settings/tokens
	* click `Generated new token`
	* Check the repo
	![](https://tva1.sinaimg.cn/large/006tNbRwgy1gayhfuoxurj319w0quaek.jpg)

## Edit Podfile

```ruby
plugin "cocoapods-cache-proxy", :proxy => "NAME" NAME 是 pod cache proxy add 命令中的 NAME

# 忽略某个依赖,走默认处理
ignore_cache_proxy_pods! ["SDWebImage"]

target 'CocopodsCacheProxy-Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'AFNetworking', :ignore_cache_proxy => true # 忽略代理,走默认处理
  pod 'SDWebImage', :cache_proxy_source => 'NAME' # NAME 是 pod cache proxy add 命令中的 NAME, 指定此依赖使用哪个代理
  # 此方式会走默认处理方式
  # http源方式会走默认处理方式
  pod 'QMUIKit', :git => 'https://github.com/Tencent/QMUI_iOS'
  # Pods for CocopodsCacheProxy-Demo

end

```
