/*
 * for sqlite3 databases 
 * db.h 
 *
 *  Created on: FEB 17, 2019
 *      Author: skerlan
 */

#ifndef DB_SQLITE3_H_
#define DB_SQLITE3_H_

#include <sqlite3.h>

#define LOOKUPGWEUI "select gweui from gws where gweui = ?;"
#define JUDGEJOINREPEAT "select appid from devs where deveui = ? and devnonce = ?;"
#define LOOKUPAPPKEY "select appkey from apps where appeui = ?;"
#define UPDATEDEVINFO "update or ignore devs set devnonce = ?, devaddr = ?, appskey = ?, nwkskey = ? where deveui = ?;"
#define INSERTUPMSG "insert or ignore into upmsg (tmst, datarate, freq, rssi, snr, fcntup, gweui, appeui, deveui, devaddr, payload) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
#define JUDGEDEVADDR "select deveui from devs where devaddr = ?;"
#define JUDGEMSGREPEAT "select deveui from upmsg where deveui = ? and tmst = ?;"
#define LOOKUPNWKSKEY "select nwkskey, appskey from devs where deveui = ?;"
#define LOOKUPPROFILE "select rx2datarate, rx2freq, id from gwprofile where id in (select profileid from gws where gweui = ?);"
#define UPDATEGWINFO "update or ignore gws set last_seen_at = ?, lati = ?, longt = ?, alti = ?, rxnb = ?, rxok = ?, rxfw = ?, ackr = ?, dwnb = ?, txnb = ? where gweui = ?;"

#define CREATEDEVS "\
CREATE TABLE IF NOT EXISTS `devs` (\
  `deveui` TEXT PRIMARY KEY DEFAULT NULL,\
  `appid` TEXT,\
  `appskey` TEXT,\
  `nwkskey` TEXT,\
  `devaddr` TEXT,\
  `fcntdown` INTEGER DEFAULT 0,\
  `fcntup` INTEGER DEFAULT 0,\
  `lasttmst` INTEGER DEFAULT 0,\
  `devnonce` TEXT DEFAULT NULL\
);"

#define CREATEGWS "\
CREATE TABLE IF NOT EXISTS `gws` (\
  `gweui` TEXT PRIMARY KEY NOT NULL,\
  `profileid` INTEGER NOT NULL DEFAULT 1,\
  `desc` TEXT NOT null DEFAULT 'draginogw',\
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\
  `last_seen_at` TEXT,\
  `maxpwdbm` INTEGER DEFAULT NULL DEFAULT 26,\
  `lati` REAL DEFAULT NULL,\
  `longt` REAL DEFAULT NULL,\
  `alti` REAL DEFAULT NULL,\
  `rxnb` INTEGER  DEFAULT 0,\
  `rxok` INTEGER  NOT NULL DEFAULT 0,\
  `rxfw` INTEGER  NOT NULL DEFAULT 0,\
  `ackr` INTEGER NOT NULL DEFAULT 0,\
  `dwnb` INTEGER  NOT NULL DEFAULT 0,\
  `txnb` INTEGER  NOT NULL DEFAULT 0,\
  `lastrxid` INTEGER  DEFAULT NULL\
);"

#define CREATEAPPS "\
CREATE TABLE IF NOT EXISTS `apps` (\
        `appeui` TEXT PRIMARY KEY NOT NULL,\
        `name` TEXT UNIQUE,\
        `appkey` TEXT NOT NULL\
);"

#define CREATEUPMSG "\
CREATE TABLE IF NOT EXISTS `upmsg` (\
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,\
  `recvtime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\
  `tmst` INTEGER NOT NULL DEFAULT 0,\
  `datarate` INTEGER DEFAULT 5,\
  `freq` REAL DEFAULT NULL,\
  `rssi` REAL DEFAULT NULL,\
  `snr` REAL DEFAULT NULL,\
  `fcntup` INTEGER NOT NULL default 0,\
  `confirmed` INTEGER NOT NULL default 0,\
  `payload` TEXT DEFAULT NULL,\
  `fport` INTEGER NOT NULL default 7,\
  `push` INTEGER NOT NULL DEFAULT 0,\
  `gweui` TEXT DEFAULT NULL,\
  `appeui` TEXT DEFAULT NULL,\
  `deveui` TEXT DEFAULT NULL,\
  `devaddr` TEXT DEFAULT NULL\
);"

#define CREATEGWPROFILE "\
CREATE TABLE IF NOT EXISTS `gwprofile` (\
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,\
  `name` TEXT UNIQUE,\
  `supportsclassc` INTEGER NOT NULL DEFAULT 1,\
  `classctimeout` INTEGER NOT NULL DEFAULT 0,\
  `macversion` TEXT NOT NULL DEFAULT '1.0.3',\
  `regparamsrevision` TEXT NOT NULL DEFAULT '1',\
  `supportsjoin` INTEGER NOT NULL DEFAULT 1,\
  `rx1delay` INTEGER NOT NULL DEFAULT 1,\
  `rx1droffset` INTEGER NOT NULL DEFAULT 0,\
  `rx2datarate` INTEGER NOT NULL DEFAULT 5,\
  `rx2freq` REAL NOT NULL DEFAULT 869.525,\
  `maxeirp` integer NOT NULL DEFAULT 1,\
  `maxdutycycle` REAL NOT NULL DEFAULT 1,\
  `rfregion` TEXT NOT NULL DEFAULT 'EU868',\
  `32bitfcnt` INTEGER NOT NULL DEFAULT 0\
);"

#define CREATECFG "\
CREATE TABLE IF NOT EXISTS `config` (\
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,\
  `cfgid` INTEGER NOT NULL DEFAULT 0,\
  `section` TEXT NOT NULL DEFAULT 'default',\
  `option` TEXT,\
  `value` TEXT\
);"

#define CREATECFGTABLE "\
CREATE TABLE IF NOT EXISTS `cfgtable` (\
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,\
  `config` TEXT UNIQUE\
);"

#define INSERTGWS "INSERT OR IGNORE INTO gws (gweui) VALUES ('A840411B7C5C4150')"
#define INSERTAPPS "INSERT OR IGNORE INTO apps (name, appeui, appkey) VALUES ('dragino', '899818FFFF290C00', '3FF71C74EE5C4F18DFF3705455910AF6')"
#define INSERTDEVS "INSERT OR IGNORE INTO devs (deveui, appid) VALUES ('6714223408593412', '899818FFFF290C00')"
#define INSERTGWPROFILE "INSERT OR IGNORE INTO gwprofile (id, name, rx2datarate, rx2freq) VALUES (1, 'EU868', 0, 869.525), \
    (2, 'US915', 8, 923.3), (3, 'EU433', 0, 434.665), (4, 'AU923', 8, 923.3), (5, 'AS923', 2, 923.2), (6, 'KR923', 0, 921.90);"
#define INSERTCFG "INSERT OR IGNORE INTO config (option, value) VALUES ('server', 'localhost'), ('upport', '1700'), ('dwport', '1701')"

#define INITSTMT(SQL, STMT) if (sqlite3_prepare_v2(cntx->db, SQL, -1, &STMT, NULL) != SQLITE_OK) {  \
									MSG_DEBUG(DEBUG_DEBUG, "failed to prepare sql; %s -> %s\n", SQL,  sqlite3_errmsg(cntx->db));\
									goto out;\
								}

#ifdef LG08_LG02
#define INITMSGSTMT(SQL, STMT) if (sqlite3_prepare_v2(cntx->msgdb, SQL, -1, &STMT, NULL) != SQLITE_OK) {  \
									MSG_DEBUG(DEBUG_DEBUG, "failed to prepare sql; %s -> %s\n", SQL, sqlite3_errmsg(cntx->msgdb));\
									goto out;\
								}
#endif

struct context {
	sqlite3* db;
#ifdef LG08_LG02
    sqlite3* msgdb;
#endif
	sqlite3_stmt* lookupgweui;
	sqlite3_stmt* judgejoinrepeat;
	sqlite3_stmt* lookupappkey;
	sqlite3_stmt* updatedevinfo; 
	sqlite3_stmt* insertupmsg; 
	sqlite3_stmt* judgedevaddr; 
	sqlite3_stmt* judgemsgrepeat; 
	sqlite3_stmt* lookupnwkskey; 
	sqlite3_stmt* lookupprofile; 
	sqlite3_stmt* updategwinfo; 
};

bool db_init(const char* dbpath, struct context* cntx);
void db_destroy(struct context* cntx);
bool db_lookup_gweui(sqlite3_stmt* stmt, char* gweui);
bool db_judge_joinrepeat(sqlite3_stmt* stmt, void* data);
bool db_lookup_appkey(sqlite3_stmt* stmt, void* data);
bool db_update_devinfo(sqlite3_stmt* stmt, void* data);
bool db_judge_devaddr(sqlite3_stmt* stmt, void* data);
bool db_judge_msgrepeat(sqlite3_stmt* stmt, char* deveui, uint32_t tmst);
bool db_lookup_nwkskey(sqlite3_stmt* stmt, void* data);
bool db_lookup_profile(sqlite3_stmt* stmt, char *gweui, int* rx2dr, float* rx2freq);
bool db_insert_upmsg(sqlite3_stmt* stmt, void* devdata, void* metadata, void* payload); 
bool db_update_gwinfo(sqlite3_stmt* stmt, void* data);

#endif   /* end defined DB_SQLITE3_H_ */
