/*
 * for dls_utili control sqlite3 databases 
 * dls_utili.h 
 *
 *  Created on: FEB 17, 2019
 *      Author: skerlan
 */

#ifndef DB_DLS_UTILI_H
#define DB_DLS_UTILI_H

#include <sqlite3.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#define DBPATH "/etc/loraserv"
#define MSGDBPATH  "/tmp/msgdb"

#define INITSTMT(SQL, STMT) if (sqlite3_prepare_v2(cntx.db, SQL, -1, &STMT, NULL) != SQLITE_OK) { \
                                MSG("failed to prepare sql; %s -> %s\n", SQL, sqlite3_errmsg(cntx.db));\
                                goto out; } 
#ifdef LG08_LG02
#define INITMSGSTMT(SQL, STMT)  if (sqlite3_prepare_v2(cntx.msgdb, SQL, -1, &STMT, NULL) != SQLITE_OK) { \
                                MSG("failed to prepare sql; %s -> %s\n", SQL, sqlite3_errmsg(cntx.msgdb));\
                                goto out; } 
#endif

#define MSG(args...)    printf(args)

#define MSG_DEBUG(FLAG, fmt, ...) \
                        do {                          \
                            if (FLAG)                 \
                                fprintf(stdout, fmt, ##__VA_ARGS__); \
                           } while (0)

struct lw_t {
    sqlite3 *db;
#ifdef LG08_LG02
    sqlite3 *msgdb;
#endif
    sqlite3_stmt *stmt;
    char appname[32];
    char pfname[32];
    char gweui[17];
    char deveui[17];
    char appeui[17];
    char devaddr[9];
    char appkey[33];
    char appskey[33];
    char nwkskey[33];
    char csvpath[48];
    uint8_t cmd;
    uint8_t rx2dr;
    uint8_t pfid;
    float rx2freq;
};

bool db_init(const char* dbpath, struct lw_t* cntx);
void db_destroy(struct lw_t* cntx);

#endif
