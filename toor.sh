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

# 临时目录使用当前目录
TMP_DIR="$SCRIPT_DIR/.ubuntu24-install-$$"

export PROOT_NO_SECCOMP=1
export PROOT_ENV=1

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

    curl -L \
        -o "$TMP_DIR/ubuntu.tar.gz" \
        "$ROOTFS_URL"

    echo
    echo "[2/5] Extracting Ubuntu..."

    mkdir -p "$ROOTFS_DIR"

    tar -xzf "$TMP_DIR/ubuntu.tar.gz" \
        -C "$ROOTFS_DIR"

    echo
    echo "[3/5] Installing PRoot..."

    mkdir -p "$ROOTFS_DIR/usr/local/bin"

    curl -L \
        -o "$TOOR" \
        "$PROOT_URL"

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

    # ------------------------------------
    # PRoot 下禁止服务自动启动
    # ------------------------------------

    mkdir -p "$ROOTFS_DIR/usr/sbin"

    cat > "$ROOTFS_DIR/usr/sbin/policy-rc.d" <<'EOF'
#!/bin/sh
exit 101
EOF

    chmod 755 "$ROOTFS_DIR/usr/sbin/policy-rc.d"

    echo "[OK] policy-rc.d configured."

    echo
    echo "[5/5] Cleaning..."

    rm -rf "$TMP_DIR"

fi


# ========================================
# 检查 PRoot
# ========================================

if [ ! -x "$TOOR" ]; then

    echo
    echo "PRoot binary missing."
    echo "Installing PRoot..."

    mkdir -p "$ROOTFS_DIR/usr/local/bin"

    curl -L \
        -o "$TOOR" \
        "$PROOT_URL"

    chmod +x "$TOOR"

fi


# ========================================
# 每次启动前修复基础配置
# ========================================


# ========================================
# DNS
# ========================================

if [ -f /etc/resolv.conf ]; then

    cp -L /etc/resolv.conf \
        "$ROOTFS_DIR/etc/resolv.conf" 2>/dev/null || true

fi


# ========================================
# policy-rc.d
# ========================================

mkdir -p "$ROOTFS_DIR/usr/sbin"

cat > "$ROOTFS_DIR/usr/sbin/policy-rc.d" <<'EOF'
#!/bin/sh
exit 101
EOF

chmod 755 "$ROOTFS_DIR/usr/sbin/policy-rc.d"



# ========================================
# APT 配置
# ========================================

mkdir -p "$ROOTFS_DIR/etc/apt"
mkdir -p "$ROOTFS_DIR/etc/apt/apt.conf.d"
mkdir -p "$ROOTFS_DIR/etc/apt/sources.list.d"

# 删除 Ubuntu Base 默认 sources
rm -f "$ROOTFS_DIR/etc/apt/sources.list.d/"*.list
rm -f "$ROOTFS_DIR/etc/apt/sources.list.d/"*.sources

cat > "$ROOTFS_DIR/etc/apt/sources.list" <<'EOF'
deb [trusted=yes] http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb [trusted=yes] http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb [trusted=yes] http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
deb [trusted=yes] http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
EOF

cat > "$ROOTFS_DIR/etc/apt/apt.conf.d/99proot" <<'EOF'
APT::Sandbox::User "root";
EOF


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
# 启动 Ubuntu
# ========================================

exec "$TOOR" \
    -r "$ROOTFS_DIR" \
    -0 \
    -w "/root" \
    $BIND_OPTS \
    --kill-on-exit
