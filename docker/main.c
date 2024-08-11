#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>
#include <string.h>
#include <time.h>
#include <dirent.h>
#include <unistd.h>

#define NUM_QUERIES 22
#define QUERY_DIR "./queries/"
#define TABLES_DIR "./tables/"
#define MAX_QUERY_LENGTH 10000
#define MAX_LINE_LENGTH 1024


void log_message(const char* message) {
    time_t now;
    time(&now);
    printf("%s\n",message);
    fflush(stdout);
}

int createTables(sqlite3 *db) {
    const char *table_creations[] = {
        "CREATE TABLE REGION (R_REGIONKEY INTEGER, R_NAME TEXT, R_COMMENT TEXT);",
        "CREATE TABLE NATION (N_NATIONKEY INTEGER, N_NAME TEXT, N_REGIONKEY INTEGER, N_COMMENT TEXT);",
        "CREATE TABLE PART (P_PARTKEY INTEGER, P_NAME TEXT, P_MFGR TEXT, P_BRAND TEXT, P_TYPE TEXT, P_SIZE INTEGER, P_CONTAINER TEXT, P_RETAILPRICE REAL, P_COMMENT TEXT);",
        "CREATE TABLE SUPPLIER (S_SUPPKEY INTEGER, S_NAME TEXT, S_ADDRESS TEXT, S_NATIONKEY INTEGER, S_PHONE TEXT, S_ACCTBAL REAL, S_COMMENT TEXT);",
        "CREATE TABLE PARTSUPP (PS_PARTKEY INTEGER, PS_SUPPKEY INTEGER, PS_AVAILQTY INTEGER, PS_SUPPLYCOST REAL, PS_COMMENT TEXT);",
        "CREATE TABLE CUSTOMER (C_CUSTKEY INTEGER, C_NAME TEXT, C_ADDRESS TEXT, C_NATIONKEY INTEGER, C_PHONE TEXT, C_ACCTBAL REAL, C_MKTSEGMENT TEXT, C_COMMENT TEXT);",
        "CREATE TABLE ORDERS (O_ORDERKEY INTEGER, O_CUSTKEY INTEGER, O_ORDERSTATUS TEXT, O_TOTALPRICE REAL, O_ORDERDATE TEXT, O_ORDERPRIORITY TEXT, O_CLERK TEXT, O_SHIPPRIORITY INTEGER, O_COMMENT TEXT);",
        "CREATE TABLE LINEITEM (L_ORDERKEY INTEGER, L_PARTKEY INTEGER, L_SUPPKEY INTEGER, L_LINENUMBER INTEGER, L_QUANTITY REAL, L_EXTENDEDPRICE REAL, L_DISCOUNT REAL, L_TAX REAL, L_RETURNFLAG TEXT, L_LINESTATUS TEXT, L_SHIPDATE TEXT, L_COMMITDATE TEXT, L_RECEIPTDATE TEXT, L_SHIPINSTRUCT TEXT, L_SHIPMODE TEXT, L_COMMENT TEXT);"
    };

    for (int i = 0; i < sizeof(table_creations) / sizeof(table_creations[0]); i++) {
        if (sqlite3_exec(db, table_creations[i], NULL, 0, NULL) != SQLITE_OK) {
            fprintf(stderr, "Error creating table: %s\n", sqlite3_errmsg(db));
            return 0;
        }
    }

    return 1;
}


int loadTables(sqlite3 *db) {
    DIR *d;
    struct dirent *dir;
    d = opendir(TABLES_DIR);
    if (!d) {
        fprintf(stderr, "Error opening tables directory %s\n", TABLES_DIR);
        return 0;
    }

    // Begin transaction
    if (sqlite3_exec(db, "BEGIN TRANSACTION;", NULL, 0, NULL) != SQLITE_OK) {
        fprintf(stderr, "Error starting transaction: %s\n", sqlite3_errmsg(db));
        closedir(d);
        return 0;
    }

    while ((dir = readdir(d)) != NULL) {
        if (strstr(dir->d_name, ".tbl")) {
            char filepath[256];
            snprintf(filepath, sizeof(filepath), "%s%s", TABLES_DIR, dir->d_name);


            FILE *file = fopen(filepath, "r");
            if (!file) {
                fprintf(stderr, "Error opening table file %s\n", filepath);
                closedir(d);
                return 0;
            }

            char table_name[256];
            snprintf(table_name, sizeof(table_name), "%.*s", (int)(strrchr(dir->d_name, '.') - dir->d_name), dir->d_name);

            char line[MAX_LINE_LENGTH];
            char query[MAX_QUERY_LENGTH];
            // Count the number of '|' in the first line,(hack to get around the error : Expected 7 args, got 8 args in Supplier insert query)
            int num_columns = 0;
            if (fgets(line, sizeof(line), file)) {
                char *token = strtok(line, "|");
                while (token) {
                    num_columns++;
                    token = strtok(NULL, "|");
                }
            }

            while (fgets(line, sizeof(line), file)) {
                snprintf(query, sizeof(query), "INSERT INTO %s VALUES (", table_name);
                char *token;
                char *rest = line;
                int count = 0;
                while ((token=strtok_r(rest, "|", &rest))) {
                    if (count >= num_columns - 1) 
                        break;

                    if (count > 0) {
                        strcat(query, ", ");
                    }

                    strcat(query, "'");
                    strcat(query, token);
                    strcat(query, "'");
                    count++;
                }
                strcat(query, ");");

                if (sqlite3_exec(db, query, NULL, 0, NULL) != SQLITE_OK) {
                    fprintf(stderr, "Error executing query: %s\n", sqlite3_errmsg(db));
                    fclose(file);
                    closedir(d);
                    return 0;
                }
            }
            fclose(file);
        }
    }

    // Commit transaction
    if (sqlite3_exec(db, "COMMIT;", NULL, 0, NULL) != SQLITE_OK) {
        fprintf(stderr, "Error committing transaction: %s\n", sqlite3_errmsg(db));
        closedir(d);
        return 0;
    }

    closedir(d);
    return 1;
}


int preLoadTables() {
    for (int i = 1; i <= 50; i++) {
        // Create a new database file for each iteration
        char db_filename[256];
        snprintf(db_filename, sizeof(db_filename), "database_%d.db", i);

        sqlite3 *db;
        char *errMsg = 0;
        int rc = sqlite3_open(db_filename, &db);
        if (rc) {
            fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
            return 0;
        }

        createTables(db);
                  
        clock_t start_load = clock();
        if (!loadTables(db)) {
            fprintf(stderr, "Error loading tables on iteration %d\n", i);
            sqlite3_close(db);
            return 0;
        }
        clock_t end_load = clock();
        double load_time_used = ((double) (end_load - start_load)) / CLOCKS_PER_SEC;
        printf("load tables,%d,%f s\n", i, load_time_used);

       
        // Close the database
        sqlite3_close(db);

        // Delete the database file after the itr
        if (remove(db_filename) != 0) {
            fprintf(stderr, "Error deleting database file %s\n", db_filename);
            return 0;
        }
    }

    return 1;
}


static int callback(void *data, int argc, char **argv, char **azColName) {
    return 0;
}

// Function to refresh new sales information (RF1)
int refreshRF1(sqlite3 *db, const char *orders_filename, const char *lineitem_filename) {
    // Begin transaction
    if (sqlite3_exec(db, "BEGIN TRANSACTION;", NULL, 0, NULL) != SQLITE_OK) {
        fprintf(stderr, "Error starting transaction: %s\n", sqlite3_errmsg(db));
        return 0;
    }

    FILE *orders_file = fopen(orders_filename, "r");
    if (!orders_file) {
        fprintf(stderr, "Error opening orders file %s\n", orders_filename);
        return 0;
    }

    FILE *lineitem_file = fopen(lineitem_filename, "r");
    if (!lineitem_file) {
        fprintf(stderr, "Error opening lineitem file %s\n", lineitem_filename);
        fclose(orders_file);
        return 0;
    }

    char orders_query[MAX_LINE_LENGTH];
    char lineitem_query[MAX_LINE_LENGTH];
    char orders_line[MAX_LINE_LENGTH];
    char lineitem_line[MAX_LINE_LENGTH];

    while (fgets(orders_line, sizeof(orders_line), orders_file) && fgets(lineitem_line, sizeof(lineitem_line), lineitem_file)) {
        // Reset query buffers
        memset(orders_query, 0, sizeof(orders_query));
        memset(lineitem_query, 0, sizeof(lineitem_query));
        snprintf(orders_query, sizeof(orders_query), "INSERT INTO ORDERS VALUES (");
        snprintf(lineitem_query, sizeof(lineitem_query), "INSERT INTO LINEITEM VALUES (");

        // Insert into ORDERS table
        char *orders_token = strtok(orders_line, "|");
        int i = 0;
        while (orders_token) {
            if (i > 0) {
                snprintf(orders_query + strlen(orders_query), sizeof(orders_query) - strlen(orders_query), ", ");
            }
            snprintf(orders_query + strlen(orders_query), sizeof(orders_query) - strlen(orders_query), "'%s'", orders_token);
            orders_token = strtok(NULL, "|");
            i++;
            if (i > 8) { // If there are more than 9 columns, stop processing
                break;
            }
        }
        snprintf(orders_query + strlen(orders_query), sizeof(orders_query) - strlen(orders_query), ");");

        // Execute the query for ORDERS
        if (sqlite3_exec(db, orders_query, NULL, 0, NULL) != SQLITE_OK) {
            fprintf(stderr, "Error executing ORDERS query: %s\n", sqlite3_errmsg(db));
            fclose(orders_file);
            fclose(lineitem_file);
            return 0;
        }

        // Insert into LINEITEM table
        char *lineitem_token = strtok(lineitem_line, "|");
        int j = 0;
        while (lineitem_token) {
            if (j > 0) {
                snprintf(lineitem_query + strlen(lineitem_query), sizeof(lineitem_query) - strlen(lineitem_query), ", ");
            }
            snprintf(lineitem_query + strlen(lineitem_query), sizeof(lineitem_query) - strlen(lineitem_query), "'%s'", lineitem_token);
            lineitem_token = strtok(NULL, "|");
            j++;
            if (j > 15) { 
                break;
            }
        }
        snprintf(lineitem_query + strlen(lineitem_query), sizeof(lineitem_query) - strlen(lineitem_query), ");");

        // Execute the query for LINEITEM
        if (sqlite3_exec(db, lineitem_query, NULL, 0, NULL) != SQLITE_OK) {
            fprintf(stderr, "Error executing LINEITEM query: %s\n", sqlite3_errmsg(db));
            fclose(orders_file);
            fclose(lineitem_file);
            return 0;
        }
    }

    // Commit transaction
    if (sqlite3_exec(db, "COMMIT;", NULL, 0, NULL) != SQLITE_OK) {
        fprintf(stderr, "Error committing transaction: %s\n", sqlite3_errmsg(db));
        return 0;
    }

    fclose(orders_file);
    fclose(lineitem_file);
    return 1;
}

int refreshRF2(sqlite3 *db, const char *delete_filename) {
    // Begin transaction
    if (sqlite3_exec(db, "BEGIN TRANSACTION;", NULL, 0, NULL) != SQLITE_OK) {
        fprintf(stderr, "Error starting transaction: %s\n", sqlite3_errmsg(db));
        return 0;
    }

    FILE *delete_file = fopen(delete_filename, "r");
    if (!delete_file) {
        fprintf(stderr, "Error opening delete file %s\n", delete_filename);
        return 0;
    }

    char delete_query[MAX_LINE_LENGTH];
    char delete_line[MAX_LINE_LENGTH];

    while(fgets(delete_line, sizeof(delete_line), delete_file)) {
        memset(delete_query, 0, sizeof(delete_query));
        snprintf(delete_query, sizeof(delete_query), "DELETE FROM ORDERS WHERE O_ORDERKEY =");

        char *delete_token = strtok(delete_line, "|");
        snprintf(delete_query + strlen(delete_query), sizeof(delete_query) - strlen(delete_query), "'%s'", delete_token);

        if (sqlite3_exec(db, delete_query, NULL, 0, NULL) != SQLITE_OK) {
            fprintf(stderr, "Error executing delete query: %s\n", sqlite3_errmsg(db));
            fclose(delete_file);
            return 0;
        }
    }

    // Commit transaction
    if (sqlite3_exec(db, "COMMIT;", NULL, 0, NULL) != SQLITE_OK) {
        fprintf(stderr, "Error committing transaction: %s\n", sqlite3_errmsg(db));
        return 0;
    }

    fclose(delete_file);
    return 1;
}

void print_time() {
    struct timespec ts;

    // Get the current time
    clock_gettime(CLOCK_REALTIME, &ts);

    // Convert time to milliseconds
    long long milliseconds = (long long)(ts.tv_sec) * 1000 + (ts.tv_nsec / 1000000);

    // Print the result
    printf("boot finish timestamp: %lld\n", milliseconds);
    
}

int main(int argc, char* argv[]) {
    
    //print_time();
    
    if (argc < 3) {
        fprintf(stderr, "Usage: %s [db_file] [num_iterations]\n", argv[0]);
        return 1;
    }

    const char *db_file = argv[1];
    int num_iterations = atoi(argv[2]);

    sqlite3 *db;
    char *errMsg = 0;
    int rc = sqlite3_open(db_file, &db);
    if (rc) {
        fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
        return 1;
    } 
    
    //log_message("Opened database successfully");
    
    //preLoadTables();

    
    
    
    char query_file[256];
    char query[MAX_QUERY_LENGTH];
    
    printf("iteration,query,time(s)\n");
    
    for (int itr = 1; itr <= num_iterations; itr++) {
     
        //snprintf(orders_filename, sizeof(orders_filename), "./refresh-data/orders.tbl.u%d", itr);
        //snprintf(lineitem_filename, sizeof(lineitem_filename), "./refresh-data/lineitem.tbl.u%d", itr);
        //snprintf(delete_filename, sizeof(delete_filename), "./refresh-data/delete.%d", itr);

        // Measure execution time of refreshRF1
        //clock_t start_rf1 = clock();
        //if (!refreshRF1(db, orders_filename, lineitem_filename)) {
        //    fprintf(stderr, "Error refreshing New Sales (RF1) for iteration %d\n", itr);
        //    sqlite3_close(db);
        //    return 1;
        //}
        //clock_t end_rf1 = clock();
        //double rf1_time_used = ((double) (end_rf1 - start_rf1)) / CLOCKS_PER_SEC;
        //printf("%d,RF1,%f seconds\n", itr, rf1_time_used);

        for (int i = 1; i <= NUM_QUERIES; i++) {
            snprintf(query_file, sizeof(query_file), QUERY_DIR "query%d.sql", i);

            FILE *fp = fopen(query_file, "r");
            if (!fp) {
                fprintf(stderr, "Can't open query file %s\n", query_file);
                continue;
            }

            // Read the query file into a string
            size_t len = fread(query, 1, sizeof(query) - 1, fp);
            query[len] = '\0';  // Ensure null termination
            fclose(fp);

             char log_msg[100];
             //snprintf(log_msg, sizeof(log_msg), "Executing Query %d", i);
             //log_message(log_msg);

            // Measure execution time
            clock_t start = clock();

            // Execute SQL select statement
            rc = sqlite3_exec(db, query, callback, (void*)query_file, &errMsg);

            // Calculate execution time
            clock_t end = clock();
            double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
            printf("%d,%d,%f\n", itr, i, cpu_time_used);

            if(rc != SQLITE_OK) {
                fprintf(stderr, "SQL error: %s\n", errMsg);
                sqlite3_free(errMsg);
            }
        }

        // Measure execution time of refreshRF2
        //clock_t start_rf2 = clock();
        //if (!refreshRF2(db, delete_filename)) {
        //    fprintf(stderr, "Error refreshing New Sales (RF2) for iteration %d\n", itr);
        //    sqlite3_close(db);
        //    return 1;
        //}
        //clock_t end_rf2 = clock();
        //double rf2_time_used = ((double) (end_rf2 - start_rf2)) / CLOCKS_PER_SEC;
        //printf("%d,RF2,%f s\n", itr, rf2_time_used);

        
    }

    // Close database
    sqlite3_close(db);
    return 0;
}
