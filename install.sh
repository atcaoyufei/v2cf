#!/bin/bash

SH_PATH=$(pwd)/cfapp
install -d ${SH_PATH}
cd ${SH_PATH}

read -p "请输入你的应用名称：" IBM_APP_NAME
echo "应用名称：${IBM_APP_NAME}"
read -p "请输入V2端口：" V2_PORT
echo "端口：${V2_PORT}"
read -p "请输入你的应用内存大小(默认256)：" IBM_MEM_SIZE
if [ -z "${IBM_MEM_SIZE}" ]; then
  IBM_MEM_SIZE=256
fi
echo "内存大小：${IBM_MEM_SIZE}"

cat >${SH_PATH}/main.py <<EOF
import os


def main():
    print(os.environ)


if __name__ == '__main__':
    main()

EOF

cat >${SH_PATH}/Procfile <<EOF
web: ./v2ray/v2ray
EOF

cat >${SH_PATH}/manifest.yml <<EOF
applications:
- path: .
  name: ${IBM_APP_NAME}
  random-route: true
  memory: ${IBM_MEM_SIZE}M
  buildpacks:
    - https://github.com/cloudfoundry/python-buildpack.git
EOF

install -d /tmp/v2ray
install -d ${SH_PATH}/v2ray

curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray ${SH_PATH}/v2ray/v2ray
install -m 755 /tmp/v2ray/v2ctl ${SH_PATH}/v2ray/v2ctl
rm -rf /tmp/v2ray

UUID=$(python -c 'import uuid; print uuid.uuid1()')
cat >${SH_PATH}/v2ray/config.json <<EOF
{
    "log":{
        "loglevel":"warning"
    },
    "inbounds": [
        {
            "port": ${V2_PORT},
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "alterId": 64
                    }
                ],
                "disableInsecureEncryption": true
            },
            "streamSettings": {
                "network": "ws"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

ibmcloud target --cf
ibmcloud cf install
ibmcloud cf push

exit 0
