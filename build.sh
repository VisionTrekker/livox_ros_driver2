#!/bin/bash
# livox_ros_driver2 ROS2 预处理脚本
#
# 职责：
#   1. 切换 package.xml（ROS1 / ROS2 二选一）
#   2. ROS2 路径下，构造 ament 启动约定的 launch/ 目录
#
# 不再负责：
#   - 调用 colcon（统一在 livo_ws 根目录用 colcon build --symlink-install）
#   - 注入 cmake-args（避免 colcon-cmake path 匹配陷阱，
#     cmake-args 由用户在调用 colcon 时通过 --cmake-args 显式传入，
#     或写入 livo_ws/.colcon/defaults.yaml 时不带 path: 过滤）

readonly VERSION_ROS1="ROS1"
readonly VERSION_ROS2="ROS2"

cd "$(dirname "$0")"
echo "Working Path: $(pwd)"

ROS_VERSION=""

# Set working ROS version
case "$1" in
  ROS1)
    ROS_VERSION=${VERSION_ROS1}
    ;;
  ROS2|humble|jazzy)
    ROS_VERSION=${VERSION_ROS2}
    ;;
  *)
    echo "Invalid Argument (use: ROS1 | ROS2 | humble | jazzy)"
    exit 1
    ;;
esac
echo "ROS version is: ${ROS_VERSION} (distro: ${ROS_DISTRO:-humble})"

# 1. 切换 package.xml
if [ -f package.xml ]; then
  rm package.xml
fi
if [ "${ROS_VERSION}" = "${VERSION_ROS1}" ]; then
  cp -f package_ROS1.xml package.xml
else
  cp -f package_ROS2.xml package.xml
fi

# 2. ROS2 路径下：构造 ament 启动约定必需的 launch/ 目录
if [ "${ROS_VERSION}" = "${VERSION_ROS2}" ]; then
  rm -rf launch/
  cp -rf launch_ROS2/ launch/
fi

echo "[build.sh] 预处理完成。请在 livo_ws 根目录执行："
echo "  colcon build --symlink-install --packages-select livox_ros_driver2 \\"
echo "    --cmake-args \"-DROS_EDITION=ROS2\" \"-DDISTRO_ROS=\${ROS_DISTRO:-humble}\""
echo "或一次性编译所有包："
echo "  colcon build --symlink-install"
echo "  （如果未通过 defaults.yaml 注入 cmake-args，请显式加上）"
