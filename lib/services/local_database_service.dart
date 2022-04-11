import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static const _databaseName = 'local.db';

  late final Database database;

  LocalDatabaseService();

  Future<void> open() async {
    var txnsPath = await getDatabasesPath();
    var path = join(txnsPath, _databaseName);

    await Directory(dirname(path)).create(recursive: true);

    database = await openDatabase(_databaseName);

    print("database opened at $path, starting setup");

    await _setup();

    print("database setup completed");
  }

  Future<void> close() async {
    await database.close();
  }

  Future<void> _setup() async {
    database.transaction((txn) async {
      await _setupAccounts(txn);
      await _setupCalendars(txn);
      await _setupContacts(txn);
      await _setupDocs(txn);
      await _setupEventModifiers(txn);
      await _setupEvents(txn);
      await _setupList(txn);
      await _setupMigrations(txn);
      await _setupTasks(txn);
    });
  }

  Future<void> _setupAccounts(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS accounts
      (
        `accountid`         VARCHAR(100) PRIMARY KEY,
        `connectorid`       VARCHAR(50),
        `originaccountid`   VARCHAR(50),
        `shortname`         VARCHAR(255),
        `fullname`          VARCHAR(255),
        `picture`           VARCHAR(255),
        `identifier`        VARCHAR(255),
        `identifierpicture` VARCHAR(255),
        `details`           JSON,
        `localdetails`      JSON,
        `createdat`         BIGINT,
        `updatedat`         BIGINT,
        `deletedat`         BIGINT,
        `remoteupdatedat`   BIGINT,
        `autologintoken`    VARCHAR(255),
        `status`            VARCHAR(255),
        `syncstatus`        VARCHAR(255),
        `id`                UUID
      )
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS accounts_accountId ON accounts(`accountId`)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS accounts_identifier ON accounts(`identifier`)
    ''');
  }

  Future<void> _setupCalendars(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS calendars
        (
          `id`                UUID PRIMARY KEY,
          `originid`          VARCHAR(255),
          `connectorid`       VARCHAR(50),
          `accountid`         VARCHAR(100),
          `originaccountid`   VARCHAR(50),
          `akiflowaccountid`  UUID,
          `title`             VARCHAR(255),
          `description`       VARCHAR(255),
          `content`           JSON,
          `primary`           BOOLEAN,
          `readonly`          BOOLEAN,
          `url`               VARCHAR(255),
          `color`             VARCHAR(10),
          `icon`              VARCHAR(255),
          `akiflowprimary`    BOOLEAN,
          `isakiflowcalendar` BOOLEAN,
          `settings`          JSON,
          `etag`              VARCHAR(255),
          `syncstatus`        VARCHAR(255),
          `remoteupdatedat`   BIGINT,
          `createdat`         BIGINT,
          `updatedat`         BIGINT,
          `deletedat`         BIGINT
        )
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS calendars_akiflowPrimary ON calendars(`akiflowPrimary`)
    ''');
  }

  Future<void> _setupContacts(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS contacts
        (
          `id`               UUID PRIMARY KEY,
          `originid`         VARCHAR(255),
          `connectorid`      VARCHAR(50),
          `akiflowaccountid` UUID,
          `originaccountid`  VARCHAR(255),
          `searchtext`       VARCHAR(255),
          `name`             VARCHAR(255),
          `identifier`       VARCHAR(255),
          `picture`          VARCHAR(255),
          `url`              VARCHAR(255),
          `localurl`         VARCHAR(255),
          `content`          JSON,
          `etag`             VARCHAR(255),
          `sorting`          BIGINT,
          `originupdatedat`  BIGINT,
          `remoteupdatedat`  BIGINT,
          `createdat`        BIGINT,
          `updatedat`        BIGINT,
          `deletedat`        BIGINT
        )
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS contacts_searchText ON contacts(`searchText`)
    ''');
  }

  Future<void> _setupDocs(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS docs
        (
          `id`              UUID PRIMARY KEY,
          `connectorid`     VARCHAR(50),
          `originid`        VARCHAR(255),
          `accountid`       VARCHAR(100),
          `originaccountid` VARCHAR(50),
          `originupdatedat` BIGINT,
          `taskid`          UUID,
          `searchtext`      VARCHAR(255),
          `title`           VARCHAR(255),
          `description`     VARCHAR(255),
          `content`         JSON,
          `icon`            VARCHAR(255),
          `url`             VARCHAR(255),
          `localurl`        VARCHAR(255),
          `type`            VARCHAR(50),
          `customtype`      VARCHAR(50),
          `important`       BOOLEAN,
          `priority`        INT,
          `sorting`         BIGINT,
          `usages`          INT,
          `lastusageat`     BIGINT,
          `pinned`          BOOLEAN,
          `hidden`          BOOLEAN,
          `customindex1`    INT,
          `customindex2`    INT,
          `createdat`       BIGINT,
          `updatedat`       BIGINT,
          `deletedat`       BIGINT,
          `remoteupdatedat` BIGINT
        )
    ''');
    await txn.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS docs_connectorId_originId ON docs(`connectorId`,`originId`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_customIndex1 ON docs(`customIndex1`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_important ON docs(`important`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_priority ON docs(`priority`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_searchText ON docs(`searchText`)');
    await txn
        .execute('CREATE INDEX IF NOT EXISTS docs_sorting ON docs(`sorting`)');
    await txn
        .execute('CREATE INDEX IF NOT EXISTS docs_taskId ON docs(`taskId`)');
    await txn
        .execute('CREATE INDEX IF NOT EXISTS docs_usages ON docs(`usages`)');
  }

  Future<void> _setupEventModifiers(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS event_modifiers
        (
          `id`               UUID PRIMARY KEY,
          `akiflowaccountid` UUID,
          `eventid`          UUID,
          `calendarid`       UUID,
          `action`           VARCHAR(255),
          `content`          JSON,
          `processedat`      BIGINT,
          `failedat`         BIGINT,
          `result`           JSON,
          `attempts`         INT,
          `remoteupdatedat`  BIGINT,
          `createdat`        BIGINT,
          `updatedat`        BIGINT,
          `deletedat`        BIGINT
        )
    ''');
  }

  Future<void> _setupEvents(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS events
        (
          `id`                        UUID PRIMARY KEY,
          `originid`                  VARCHAR(255),
          `customoriginid`            VARCHAR(255),
          `connectorid`               VARCHAR(50),
          `accountid`                 VARCHAR(100),
          `akiflowaccountid`          UUID,
          `originaccountid`           VARCHAR(50),
          `recurringid`               UUID,
          `originrecurringid`         VARCHAR(255),
          `calendarid`                VARCHAR(255),
          `origincalendarid`          VARCHAR(255),
          `creatorid`                 VARCHAR(255),
          `organizerid`               VARCHAR(255),
          `originalstarttime`         BIGINT,
          `originalstartdate`         VARCHAR(10),
          `starttime`                 BIGINT,
          `endtime`                   BIGINT,
          `startdate`                 VARCHAR(10),
          `enddate`                   VARCHAR(10),
          `startdatetimetz`           VARCHAR(255),
          `enddatetimetz`             VARCHAR(255),
          `originupdatedat`           BIGINT,
          `etag`                      VARCHAR(255),
          `title`                     VARCHAR(255),
          `description`               VARCHAR(255),
          `content`                   JSON,
          `attendees`                 JSON,
          `recurrence`                JSON,
          `recurrenceexception`       BOOLEAN,
          `declined`                  BOOLEAN,
          `readonly`                  BOOLEAN,
          `hidden`                    BOOLEAN,
          `url`                       VARCHAR(255),
          `meetingstatus`             VARCHAR(255),
          `meetingurl`                VARCHAR(255),
          `meetingicon`               VARCHAR(255),
          `meetingsolution`           VARCHAR(100),
          `color`                     VARCHAR(10),
          `calendarcolor`             VARCHAR(10),
          `taskid`                    UUID,
          `fingerprints`              JSON,
          `remoteupdatedat`           BIGINT,
          `createdat`                 BIGINT,
          `updatedat`                 BIGINT,
          `deletedat`                 BIGINT,
          `untildatetime`             BIGINT,
          `recurrenceexceptiondelete` BOOLEAN,
          `recurrencesyncretry`       INTEGER
        )
    ''');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_endDate ON events(`endDate`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_endTime ON events(`endTime`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_recurringId ON events(`recurringId`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_startDate ON events(`startDate`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_startTime ON events(`startTime`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_taskId ON events(`taskId`)');
  }

  Future<void> _setupList(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS lists
        (
          `id`              UUID PRIMARY KEY,
          `title`           VARCHAR(255),
          `icon`            VARCHAR(255),
          `color`           VARCHAR(255),
          `createdat`       BIGINT,
          `updatedat`       BIGINT,
          `deletedat`       BIGINT,
          `sorting`         BIGINT,
          `remoteupdatedat` BIGINT,
          "parentid"        UUID,
          `isfolder`        BOOLEAN,
          `system`          VARCHAR(255),
          `type`            VARCHAR(255)
        )
    ''');
  }

  Future<void> _setupMigrations(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS migrations(`name` VARCHAR(255) PRIMARY KEY ,`createdAt` BIGINT )
    ''');
  }

  Future<void> _setupTasks(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS tasks
        (
          `id`              UUID PRIMARY KEY,
          `title`           VARCHAR(255),
          `date`            DATE,
          `datetime`        BIGINT,
          `recurringid`     UUID,
          `recurrence`      JSON,
          `description`     TEXT,
          `searchtext`      VARCHAR(255),
          `links`           JSON,
          `status`          TINYINT,
          `done`            INT,
          `doneat`          BIGINT,
          `duration`        INT,
          `priority`        TINYINT,
          `sorting`         BIGINT,
          `important`       BOOLEAN,
          `listid`          UUID,
          `content`         JSON,
          `location`        JSON,
          `attendees`       JSON,
          `readat`          BIGINT,
          `createdat`       BIGINT,
          `updatedat`       BIGINT,
          `deletedat`       BIGINT,
          `dailygoal`       BIGINT,
          `origin`          BIGINT,
          `remoteupdatedat` BIGINT,
          `sectionid`       UUID,
          `sortinglabel`    INTEGER,
          `duedate`         DATE
        )
    ''');
  }
}
