#!/bin/bash


if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <dbgen_size> <test: power,boot>"
    exit 1
fi

DBGEN_SIZE=$1
TEST=$2

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Install dependencies
echo "OSv: Setting up dependencies..."
cd unikernel
sudo ./scripts/setup.py > build/setup.log 2>&1
cd ..
echo "OSv: Setup successful."

if [ "$TEST" = "power" ]; then
    # If test is power, we need to build the images with the files and the queries
    echo "OSv: Preparing TPC-H files..."

    cd .. 
#    cp TPCH-sqlite/TPC-H-$DBGEN_SIZE.db osv/apps/sqlite/tpch-data 
    cp TPCH-sqlite/sqlite-ddl.sql osv/unikernel/apps/sqlite/tpch-queries
    cp TPCH-sqlite/tpch-dbgen/*.tbl osv/unikernel/apps/sqlite/tpch-data
    python3 "$SCRIPT_DIR/unikernel/apps/sqlite/tpch-data/remove-last-separator.py" > "$SCRIPT_DIR/unikernel/build/remove-last-separator.logs"
    #python3 osv/apps/sqlite/tpch-data/remove-last-separator.py > osv/unikernel/build/remove-last-separator.logs
    cp queries/* osv/unikernel/apps/sqlite/tpch-queries
    cd osv

    # Now we need to adjust the usr.manifest
    echo '/usr/lib/libsqlite3.so.0: ${MODULE_DIR}/libsqlite3.so.0
/query1.sql: ${MODULE_DIR}/tpch-queries/query1.sql
/query2.sql: ${MODULE_DIR}/tpch-queries/query2.sql
/query3.sql: ${MODULE_DIR}/tpch-queries/query3.sql
/query4.sql: ${MODULE_DIR}/tpch-queries/query4.sql
/query5.sql: ${MODULE_DIR}/tpch-queries/query5.sql
/query6.sql: ${MODULE_DIR}/tpch-queries/query6.sql
/query7.sql: ${MODULE_DIR}/tpch-queries/query7.sql
/query8.sql: ${MODULE_DIR}/tpch-queries/query8.sql
/query9.sql: ${MODULE_DIR}/tpch-queries/query9.sql
/query10.sql: ${MODULE_DIR}/tpch-queries/query10.sql
/query11.sql: ${MODULE_DIR}/tpch-queries/query11.sql
/query12.sql: ${MODULE_DIR}/tpch-queries/query12.sql
/query13.sql: ${MODULE_DIR}/tpch-queries/query13.sql
/query14.sql: ${MODULE_DIR}/tpch-queries/query14.sql
/query15.sql: ${MODULE_DIR}/tpch-queries/query15.sql
/query16.sql: ${MODULE_DIR}/tpch-queries/query16.sql
/query17.sql: ${MODULE_DIR}/tpch-queries/query17.sql
/query18.sql: ${MODULE_DIR}/tpch-queries/query18.sql
/query19.sql: ${MODULE_DIR}/tpch-queries/query19.sql
/query20.sql: ${MODULE_DIR}/tpch-queries/query20.sql
/query21.sql: ${MODULE_DIR}/tpch-queries/query21.sql
/query22.sql: ${MODULE_DIR}/tpch-queries/query22.sql
/customer.tbl: ${MODULE_DIR}/tpch-data/customer.tbl
/nation.tbl: ${MODULE_DIR}/tpch-data/nation.tbl
/orders.tbl: ${MODULE_DIR}/tpch-data/orders.tbl
/part.tbl: ${MODULE_DIR}/tpch-data/part.tbl
/partsupp.tbl: ${MODULE_DIR}/tpch-data/partsupp.tbl
/region.tbl: ${MODULE_DIR}/tpch-data/region.tbl
/supplier.tbl: ${MODULE_DIR}/tpch-data/supplier.tbl
/lineitem.tbl: ${MODULE_DIR}/tpch-data/lineitem.tbl
/sqlite-ddl.sql: ${MODULE_DIR}/tpch-queries/sqlite-ddl.sql' > unikernel/apps/sqlite/usr.manifest

    echo "OSv: TPC-H files are ready for image build."

    echo "OSv: Building sqlite image..."
    echo "OSv: If it's the first time you're building it, it might take a while..."
    
    # now that the usr.manifest is clean, we need to build the unikernel image
    cd unikernel
    ./scripts/build image=sqlite > build/build.log 2>&1
    cd ..

    last_line=$(tail -n 1 unikernel/build/build.log | tr -d '\n')

    if echo "$last_line" | grep -q "cpiod finished"; then
        echo "OSv: sqlite image for power test built successfully!"
    else
        echo "OSv: sqlite image build for power test failed! Check logs in the build directory!"
    fi


elif [ "$TEST" = "boot" ]; then
    # if the test is boot, we don't need any data
    # meaning we need to keep the usr.manifest clean without any data
    # cd apps/sqlite/usr.manifest
    echo '/usr/lib/libsqlite3.so.0: ${MODULE_DIR}/libsqlite3.so.0' > unikernel/apps/sqlite/usr.manifest

    echo "OSv: Building sqlite image..."
    echo "OSv: If it's the first time you're building it, it might take a while..."

    # now that the usr.manifest is clean, we need to build the unikernel image
    cd unikernel
    ./scripts/build image=sqlite > build/build.log 2>&1
    cd ..

    last_line=$(tail -n 1 unikernel/build/build.log | tr -d '\n')

    if echo "$last_line" | grep -q "cpiod finished"; then
        echo "OSv: sqlite image for boot test built successfully!"
    else
        echo "OSv: sqlite image build for boot test failed! Check logs in the build directory!"
    fi
fi