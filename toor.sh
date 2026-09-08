#!/bin/bash

set -e

# ========================================
# Ubuntu 24.04 PRoot 一体化启动脚本
# 普通用户可运行
# ========================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ROOT_BASE="$SCRIPT_DIR"
ROOTFS_DIR="$ROOT_BASE/Ubuntu24"
TOOR="$ROOTFS_DIR/usr/local/bin/toor"

# Ubuntu Base 24.04.4 amd64
ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/24.04.4/release/ubuntu-base-24.04.4-base-amd64.tar.gz"

# PRoot
PROOT_URL="https://raw.githubusercontent.com/kof96zip/MyWorlds/main/proot-x86_64"

TMP_DIR="/tmp/ubuntu24-install-$$"

export PROOT_NO_SECCOMP=1


# ========================================
# 基础检查
# ========================================

echo "========================================"
echo " Ubuntu 24.04 PRoot"
echo "========================================"
echo "User   : $(whoami)"
echo "UID    : $(id -u)"
echo "WorkDir: $SCRIPT_DIR"
echo "========================================"
echo


# ========================================
# 检查当前目录权限
# ========================================

if [ ! -w "$SCRIPT_DIR" ]; then
    echo "ERROR: Current directory is not writable."
    echo "Directory: $SCRIPT_DIR"
    exit 1
fi


# ========================================
# 安装 Ubuntu24
# ========================================

if [ ! -d "$ROOTFS_DIR/etc" ]; then

    echo
    echo "========================================"
    echo " Ubuntu 24.04 not found"
    echo " Installing..."
    echo "========================================"
    echo

    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    echo "[1/5] Downloading Ubuntu 24.04.4..."

    curl -L -o "$TMP_DIR/ubuntu.tar.gz" "$ROOTFS_URL"

    echo
    echo "[2/5] Extracting Ubuntu..."

    mkdir -p "$ROOTFS_DIR"

    tar -xzf "$TMP_DIR/ubuntu.tar.gz" \
        -C "$ROOTFS_DIR"

    echo
    echo "[3/5] Installing PRoot..."

    mkdir -p "$ROOTFS_DIR/usr/local/bin"

    curl -L -o "$TOOR" "$PROOT_URL"

    chmod +x "$TOOR"

    echo
    echo "[4/5] Configuring Ubuntu..."

    # DNS
    mkdir -p "$ROOTFS_DIR/etc"

    if [ -f /etc/resolv.conf ]; then
        cp -L /etc/resolv.conf \
            "$ROOTFS_DIR/etc/resolv.conf"
    fi

    # 基础目录
    mkdir -p \
        "$ROOTFS_DIR/proc" \
        "$ROOTFS_DIR/sys" \
        "$ROOTFS_DIR/dev" \
        "$ROOTFS_DIR/root"

    echo
    echo "[5/5] Cleaning..."

    rm -rf "$TMP_DIR"

    echo
    echo "========================================"
    echo " Ubuntu 24.04 installation completed"
    echo "========================================"
    echo

else

    echo
    echo "========================================"
    echo " Ubuntu 24.04 detected"
    echo " Skipping installation"
    echo "========================================"
    echo

fi


# ========================================
# 检查 PRoot
# ========================================

if [ ! -x "$TOOR" ]; then

    echo "PRoot binary missing."
    echo "Installing PRoot..."

    mkdir -p "$ROOTFS_DIR/usr/local/bin"

    curl -L -o "$TOOR" "$PROOT_URL"

    chmod +x "$TOOR"

fi


# ========================================
# 更新 DNS
# ========================================

if [ -f /etc/resolv.conf ]; then
    cp -L /etc/resolv.conf \
        "$ROOTFS_DIR/etc/resolv.conf" 2>/dev/null || true
fi


# ========================================
# PRoot Bind
# ========================================

BIND_OPTS=""

if [ -d /dev ]; then
    BIND_OPTS="$BIND_OPTS -b /dev"
fi

if [ -d /proc ]; then
    BIND_OPTS="$BIND_OPTS -b /proc"
fi

if [ -d /sys ]; then
    BIND_OPTS="$BIND_OPTS -b /sys"
fi

if [ -f /etc/resolv.conf ]; then
    BIND_OPTS="$BIND_OPTS -b /etc/resolv.conf"
fi


# ========================================
# 启动
# ========================================

echo "========================================"
echo " Starting Ubuntu 24.04 PRoot"
echo "========================================"
echo "RootFS : $ROOTFS_DIR"
echo "Arch   : $(uname -m)"
echo "PRoot  : $TOOR"
echo "User   : $(whoami)"
echo "========================================"
echo

exec "$TOOR" \
    --rootfs="$ROOTFS_DIR" \
    -0 \
    -w "/root" \
    $BIND_OPTS \
    --kill-on-exit