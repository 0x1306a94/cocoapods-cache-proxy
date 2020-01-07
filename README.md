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

## Edit Podfile

```ruby
plugin "cocoapods-cache-proxy", :proxy => "NAME" NAME 是 pod cache proxy add 命令中的 NAME

ignore_cache_proxy_pods! ["SDWebImage"]

target 'CocopodsCacheProxy-Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
	pod 'AFNetworking'
	pod 'SDWebImage'
  # 此方式会走官方默认处理方式
  # http源方式会走官方默认处理方式
  pod 'QMUIKit', :git => 'https://github.com/Tencent/QMUI_iOS'
  # Pods for CocopodsCacheProxy-Demo

end

```

