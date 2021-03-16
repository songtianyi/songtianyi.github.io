# kong 插件开发

### 说明

本文档记录了开发 kong 插件所需注意的要点

### 关于 kong 插件开发文档

开发插件之前，至少阅读一遍开发文档，卡壳儿的时候及时回顾文档

https://docs.konghq.com/0.14.x/plugin-development/

特别注意文档的版本，需要和你所使用的 kong 的版本相匹配，否则写出来的代码不兼容。

``` bash
kong version
```

另外，可以参考 kong 内置的插件代码, 足够我们进行 copy&paste

``` bash
find . -name handler.lua
```

通过 grep 发现，内置插件中并没有 http 请求的代码，补充如下:

``` lua
  token, err = retrieve_token(conf)
  local resp = {}
  r, c, h = http.request {
    method = "GET",
    headers = {
      Authorization = token
    },
    url = "http://192.168.1.150/api/roles",
    sink=ltn12.sink.table(resp)
  }
  kong.log.inspect(r, c, h, resp)
```

注: 如果使用 docker/k8s 部署的 kong，请先登录容器然后再执行上述命令

### 打包代码

使用[luarocks](https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix) 打包，文档里有写，这里给出一个实际例子。

打包前需要编写一个配置文件，参考如下

``` lua
package = "kong-plugin-rbac"
version = "1.0.0-1"
-- The version '1.0.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- TODO: This is the name to set in the Kong configuration `plugins` setting.
-- Here we extract it from the package name.
local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}
source = {
  url = "http://sky-cloud.net",
  tag = "1.0.0"
}

description = {
  summary = "rbac plugin for sky-cloud services",
  homepage = "http://sky-cloud.net",
  license = "private"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    -- TODO: add any additional files that the plugin consists of
    -- 根据自己的实际路径去修改
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}
```

打包命令

``` bash
luarocks pack kong-plugin-rbac 1.0.0-1
```

上传到服务器，并安装，安装命令如下:

``` 
luarocks install kong-plugin-rbac-1.0.0-1.all.rock
```

### docker 环境下 kong 插件部署

在 docker 环境下 kong 插件的部署要较麻烦一些，需要做路径映射，将本地安装的 kong 插件映射到容器内，同时修改 lua 包的搜索路径。kong 的配置文件里的参数都是可以通过环境变量控制的，变量名的规律为 xx_xx, KONG_XX_XX, 比如 lua_package_path 参数对应的环境变量名为 KONG_LUA_PACKAGE_PATH.

``` yaml
    volumeMounts:

        - name: tz

          mountPath: /etc/localtime

        - name: rbac

          mountPath: /kong/plugins/rbac/

        - name: logs

          mountPath: /usr/local/kong/logs/
      volumes:

      - name: tz

        hostPath:
          path: /etc/localtime

      - name: rbac

        hostPath:
          path: /usr/local/share/lua/5.1/kong/plugins/rbac/

      - name : logs

        hostPath:
          path: /srv/nap/kong/logs/
```

如上所示，将本地的 rbac 插件目录，映射到了容器内。然后按照如下的方式修改注入环境变量。

先使用 luarocks 将代码打包, 打包需要一个配置文件，参考如下

``` yaml

        - name: KONG_LUA_PACKAGE_PATH

          value: /usr/lib64/lua/5.1/?.lua;/usr/lib64/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;./?.lua;./?/init.lua;/usr/local/share/lua/5.1/kong/plugins/rbac/?.lua;

        - name: KONG_LOG_LEVEL

          value: debug

        - name: KONG_PLUGINS

          value: rbac,jwt-keycloak,oidc,acl,aws-lambda,azure-functions,basic-auth,bot-detection,correlation-id,cors,datadog,file-log,hmac-auth,http-log,ip-restriction,jwt,key-auth,ldap-auth,loggly,oauth2,post-function,pre-function,prometheus,rate-limiting,request-size-limiting,request-termination,request-transformer,statsd,syslog,tcp-log,udp-log,zipkin
```

### 执行顺序

kong 的多个插件是按照优先级依次执行的，要注意这点，方便按照预期的方式调试/验证代码.

``` lua
local RBACHandler =  BasePlugin:extend()

local priority_env_var = "KONG_RBAC_PRIORITY"
local priority
if os.getenv(priority_env_var) then
    priority = tonumber(os.getenv(priority_env_var))
else
    -- priority = 1500
    priority = 999
end
kong.log.debug('KONG_RBAC_PRIORITY: ' .. priority)
```

内置插件的优先级可以参考文档，保证自己开发的插件在合适的时机运行。

### PDK

pdk 是 kong 提供的插件开发包，方便我们在不同插件之间共享数据，以及操作 db，使用方式比较简单，参考文档即可，但要注意文档的版本。
