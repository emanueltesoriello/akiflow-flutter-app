import 'dart:async';

import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  late final Database database;

  LocalDatabaseService();

  Future<void> open() async {
    database = await openDatabase('local.db');

    await _setup();
  }

  Future<void> close() async {
    await database.close();
  }

  Future<void> _setup() async {
    await _setupAccounts();
    await _setupCalendars();
    await _setupContacts();
    await _setupDocs();
    await _setupEventModifiers();
    await _setupEvents();
    await _setupList();
    await _setupMigrations();
    await _setupTasks();
  }

  Future<void> _setupAccounts() async {
    await database.execute('''
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
    await database.execute('''
      CREATE INDEX accounts_accountId ON accounts(`accountId`)
    ''');
    await database.execute('''
      CREATE INDEX accounts_identifier ON accounts(`identifier`)
    ''');
  }

  Future<void> _setupCalendars() async {
    await database.execute('''
      CREATE TABLE calendars
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
      )
    ''');
    await database.execute('''
      CREATE INDEX calendars_akiflowPrimary ON calendars(`akiflowPrimary`)
    ''');
  }

  Future<void> _setupContacts() async {
    await database.execute('''
      CREATE TABLE contacts
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
    await database.execute('''
      CREATE INDEX contacts_searchText ON contacts(`searchText`)
    ''');
  }

  Future<void> _setupDocs() async {
    await database.execute('''
      CREATE TABLE docs
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
    await database.execute(
        'CREATE UNIQUE INDEX docs_connectorId_originId ON docs(`connectorId`,`originId`)');
    await database
        .execute('CREATE INDEX docs_customIndex1 ON docs(`customIndex1`)');
    await database.execute('CREATE INDEX docs_important ON docs(`important`)');
    await database.execute('CREATE INDEX docs_priority ON docs(`priority`)');
    await database
        .execute('CREATE INDEX docs_searchText ON docs(`searchText`)');
    await database.execute('CREATE INDEX docs_sorting ON docs(`sorting`)');
    await database.execute('CREATE INDEX docs_taskId ON docs(`taskId`)');
    await database.execute('CREATE INDEX docs_usages ON docs(`usages`)');
  }

  Future<void> _setupEventModifiers() async {
    await database.execute('''
      CREATE TABLE event_modifiers
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

  Future<void> _setupEvents() async {
    await database.execute('''
      CREATE TABLE events
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
    await database.execute('CREATE INDEX events_endDate ON events(`endDate`)');
    await database.execute('CREATE INDEX events_endTime ON events(`endTime`)');
    await database
        .execute('CREATE INDEX events_recurringId ON events(`recurringId`)');
    await database
        .execute('CREATE INDEX events_startDate ON events(`startDate`)');
    await database
        .execute('CREATE INDEX events_startTime ON events(`startTime`)');
    await database.execute('CREATE INDEX events_taskId ON events(`taskId`)');
  }

  Future<void> _setupList() async {
    await database.execute('''
      CREATE TABLE lists
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

  Future<void> _setupMigrations() async {
    await database.execute('''
      CREATE TABLE migrations(`name` VARCHAR(255) PRIMARY KEY ,`createdAt` BIGINT )
    ''');
  }

  Future<void> _setupTasks() async {
    await database.execute('''
      CREATE TABLE tasks
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
