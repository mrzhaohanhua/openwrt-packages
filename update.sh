#!/bin/bash

if ! git pull; then
    echo "代码拉取失败."
    exit 1
fi

passwall_version="25.7.6-1"
download_path="download"

rm -rf "$download_path"
mkdir "$download_path"

# 下载 SmartDNS
echo "更新 SmartDNS"
git clone --depth 1 https://github.com/pymumu/openwrt-smartdns "$download_path/openwrt-smartdns"
git clone --depth 1 https://github.com/pymumu/luci-app-smartdns "$download_path/luci-app-smartdns"

# 下载 Passwall
echo "更新 Passwall"
git clone --depth 1 -b $passwall_version https://github.com/xiaorouji/openwrt-passwall "$download_path/openwrt-passwall"
rm -rf $download_path/luci-app-passwall
mv $download_path/openwrt-passwall/luci-app-passwall $download_path
rm -rf $download_path/openwrt-passwall


# 下载 Passwall Packages
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages $download_path/openwrt-passwall-packages
mv $download_path/openwrt-passwall-packages/* $download_path
rm -rf $download_path/openwrt-passwall-packages

# 下载 argon主题
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon $download_path/luci-theme-argon
# 下载 argon-config
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config $download_path/luci-app-argon-config

# 清理 git 文件
find "$download_path" -type d -name ".git" -exec rm -rf {} \;
find "$download_path" -type d -name ".github" -exec rm -rf {} \;
find "$download_path" -type f -name ".gitignore" -exec rm -rf {} \;

# 将下载的软件包复制出来
for package_path in $download_path/*/; do
    package_name=$(basename $package_path)
    rm -rf "$package_name"
    echo "复制 $package_path 到 $package_name"
    cp -r "$package_path" "$package_name"
done

# 清理
echo "清理$download_path"
rm -rf "$download_path"

if [ -z $(git diff) ]; then
    echo "仓库代码没有变化."
    exit 0
fi

commit_time=$(date +"%Y-%m-%d_%H_%M_%S")
git add .

git commit -m "update $commit_time"
if [ $? -ne 0 ]; then
    echo "commit $commit_time 失败."
    return 1
fi

git push
if [ $? -ne 0 ]; then
    echo "git push 失败."
    return 1
fi
echo "更新成功. with commit $commit_time."
