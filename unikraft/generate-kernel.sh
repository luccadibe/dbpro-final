#!/bin/bash


if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <dbgen_size> <test: power,boot>"
    exit 1
fi


if [ $TEST = "power" ]; then
    # if there is a db of the specified size in the rootfs, use it
    # if not, erase the current db and use the new one
    if [ ! -e "rootfs/TPC-H-$1.db" ]; then
        rm -f rootfs/TPC-H-*.db
        cp ../TPCH-sqlite/TPC-H-$1.db rootfs/
    fi
    #if the queries are not in the rootfs, copy them
    if [ ! -e "rootfs/query1.sql" ]; then
        cp ../queries/* rootfs/
    fi
    cat <<EOF > Kraftfile
spec: v0.6

name: sqlite

rootfs: ./rootfs

cmd:
  [
    "/TPC-H-$DBGEN_SIZE.db",
    ".timer 'on'",
    ".read 'query1.sql'",
    ".read 'query2.sql'",
    ".read 'query3.sql'",
    ".read 'query4.sql'",
    ".read 'query5.sql'",
    ".read 'query6.sql'",
    ".read 'query7.sql'",
    ".read 'query8.sql'",
    ".read 'query9.sql'",
    ".read 'query10.sql'",
    ".read 'query11.sql'",
    ".read 'query12.sql'",
    ".read 'query13.sql'",
    ".read 'query14.sql'",
    ".read 'query15.sql'",
    ".read 'query16.sql'",
    ".read 'query17.sql'",
    ".read 'query18.sql'",
    ".read 'query19.sql'",
    ".read 'query20.sql'",
    ".read 'query21.sql'",
    ".read 'query22.sql'",
  ]

unikraft:
  version: staging
  kconfig:
    CONFIG_LIBRAMFS: "y"
    CONFIG_LIBUKBUS: "y"
    CONFIG_LIBUKCPIO: "y"
    CONFIG_LIBUKDEBUG_ANSI_COLOR: "y"
    CONFIG_LIBUKLIBPARAM: "y"
    CONFIG_LIBPOSIX_MMAP: "y"
    CONFIG_LIBPOSIX_SYSINFO: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_CI_EINITRD: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_CI: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB0_DEV: "embedded"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB0_DRIVER: "extract"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB0_MP: "/"
    CONFIG_LIBVFSCORE_AUTOMOUNT_UP: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT: "y"

targets:
  - qemu/x86_64
  - qemu/arm64
  - fc/x86_64
  - fc/arm64

libraries:
  musl: stable
  sqlite:
    version: stable
    kconfig:
      CONFIG_LIBSQLITE_MAIN_FUNCTION: "y"
EOF
    
    elif [ $TEST = "boot" ]; then
    if [  -e "rootfs/query1.sql" ]; then
        rm query*.sql
    fi
    cat <<EOF > Kraftfile
spec: v0.6

name: sqlite

rootfs: ./rootfs

cmd:
  [".exit"]

unikraft:
  version: staging
  kconfig:
    CONFIG_LIBRAMFS: "y"
    CONFIG_LIBUKBUS: "y"
    CONFIG_LIBUKCPIO: "y"
    CONFIG_LIBUKDEBUG_ANSI_COLOR: "y"
    CONFIG_LIBUKLIBPARAM: "y"
    CONFIG_LIBPOSIX_MMAP: "y"
    CONFIG_LIBPOSIX_SYSINFO: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_CI_EINITRD: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_CI: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB0_DEV: "embedded"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB0_DRIVER: "extract"
    CONFIG_LIBVFSCORE_AUTOMOUNT_FB0_MP: "/"
    CONFIG_LIBVFSCORE_AUTOMOUNT_UP: "y"
    CONFIG_LIBVFSCORE_AUTOMOUNT: "y"

targets:
  - qemu/x86_64
  - qemu/arm64
  - fc/x86_64
  - fc/arm64

libraries:
  musl: stable
  sqlite:
    version: stable
    kconfig:
      CONFIG_LIBSQLITE_MAIN_FUNCTION: "y"
EOF
fi

# build the unikernel
kraft build --target qemu/x86_64