import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseService {
  static const _databaseName = 'local.db';

  sql.Database? database;

  DatabaseService();

  Future<sql.Database> open() async {
    if (database != null) {
      database = null;
    }

    var databsePath = await sql.getDatabasesPath();
    var path = join(databsePath, _databaseName);

    await Directory(dirname(path)).create(recursive: true);

    database = await sql.openDatabase(_databaseName);

    print("database opened at $path, starting setup");

    await _setup();

    print("database setup completed");

    return database!;
  }

  Future<void> delete() async {
    if (database == null) {
      return;
    }

    await sql.deleteDatabase(database!.path);

    try {
      File(database!.path).deleteSync();
    } catch (_) {}

    await open();
  }

  Future<void> _setup() async {
    database!.transaction((txn) async {
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
CREATE TABLE IF NOT EXISTS accounts(
  `account_id` VARCHAR(100) PRIMARY KEY,
  `connector_id` VARCHAR(50),
  `origin_account_id` VARCHAR(50),
  `short_name` VARCHAR(255),
  `full_name` VARCHAR(255),
  `picture` VARCHAR(255),
  `identifier` VARCHAR(255),
  `identifier_picture` VARCHAR(255),
  `details` TEXT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT,
  `remote_updated_at` TEXT,
  `autologin_token` VARCHAR(255),
  `status` VARCHAR(255),
  `sync_status` VARCHAR(255),
  `id` UUID
)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS accounts_account_id ON accounts(`account_id`)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS accounts_identifier ON accounts(`identifier`)
    ''');
  }

  Future<void> _setupCalendars(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS calendars(
  `id` UUID PRIMARY KEY,
  `origin_id` VARCHAR(255),
  `connector_id` VARCHAR(50),
  `account_id` VARCHAR(100),
  `origin_account_id` VARCHAR(50),
  `akiflow_account_id` UUID,
  `title` VARCHAR(255),
  `description` VARCHAR(255),
  `content` TEXT,
  `primary` INTEGER,
  `read_only` INTEGER,
  `url` VARCHAR(255),
  `color` VARCHAR(10),
  `icon` VARCHAR(255),
  `akiflow_primary` INTEGER,
  `is_akiflow_calendar` INTEGER,
  `settings` TEXT,
  `etag` VARCHAR(255),
  `sync_status` VARCHAR(255),
  `remote_updated_at` TEXT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT
)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS calendars_akiflow_primary ON calendars(`akiflow_primary`)
    ''');
  }

  Future<void> _setupContacts(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS contacts(
  `id` UUID PRIMARY KEY,
  `origin_id` VARCHAR(255),
  `connector_id` VARCHAR(50),
  `akiflow_account_id` UUID,
  `origin_account_id` VARCHAR(255),
  `search_text` VARCHAR(255),
  `name` VARCHAR(255),
  `identifier` VARCHAR(255),
  `picture` VARCHAR(255),
  `url` VARCHAR(255),
  `local_url` VARCHAR(255),
  `content` TEXT,
  `etag` VARCHAR(255),
  `sorting` INTEGER,
  `origin_updated_at` TEXT,
  `remote_updated_at` TEXT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT
)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS contacts_search_text ON contacts(`search_text`)
    ''');
  }

  Future<void> _setupDocs(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS docs(
  `id` UUID PRIMARY KEY,
  `connector_id` VARCHAR(50),
  `origin_id` VARCHAR(255),
  `account_id` VARCHAR(100),
  `origin_account_id` VARCHAR(50),
  `origin_updated_at` TEXT,
  `task_id` UUID,
  `search_text` VARCHAR(255),
  `title` VARCHAR(255),
  `description` VARCHAR(255),
  `content` TEXT,
  `icon` VARCHAR(255),
  `url` VARCHAR(255),
  `local_url` VARCHAR(255),
  `type` VARCHAR(50),
  `custom_type` VARCHAR(50),
  `important` INTEGER,
  `priority` INT,
  `sorting` INTEGER,
  `usages` INT,
  `last_usage_at` TEXT,
  `pinned` INTEGER,
  `hidden` INTEGER,
  `custom_index1` INT,
  `custom_index2` INT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT,
  `remote_updated_at` TEXT,
  `from` TEXT,
  `internalDate` TEXT,
  `initialSyncMode` INTEGER
)
    ''');
    await txn
        .execute('CREATE UNIQUE INDEX IF NOT EXISTS docs_connector_id_origin_id ON docs(`connector_id`,`origin_id`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_custom_index1 ON docs(`custom_index1`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_important ON docs(`important`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_priority ON docs(`priority`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_search_text ON docs(`search_text`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_sorting ON docs(`sorting`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_task_id ON docs(`task_id`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS docs_usages ON docs(`usages`)');
  }

  Future<void> _setupEventModifiers(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS event_modifiers(
  `id` UUID PRIMARY KEY,
  `akiflow_account_id` UUID,
  `event_id` UUID,
  `calendar_id` UUID,
  `action` VARCHAR(255),
  `content` TEXT,
  `processed_at` TEXT,
  `failed_at` TEXT,
  `result` TEXT,
  `attempts` INT,
  `remote_updated_at` TEXT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT
)
    ''');
  }

  Future<void> _setupEvents(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS events(
  `id` UUID PRIMARY KEY,
  `customorigin_id` VARCHAR(255),
  `connector_id` VARCHAR(50),
  `account_id` VARCHAR(100),
  `akiflow_account_id` UUID,
  `origin_id` VARCHAR(255),
  `origin_account_id` VARCHAR(50),
  `origin_calendar_id` TEXT,
  `recurring_id` UUID,
  `custom_origin_id` UUID,
  `origin_recurring_id` VARCHAR(255),
  `calendar_id` VARCHAR(255),
  `origincalendar_id` VARCHAR(255),
  `creator_id` VARCHAR(255),
  `organizer_id` VARCHAR(255),
  `original_start_time` TEXT,
  `original_start_date` VARCHAR(10),
  `start_time` TEXT,
  `end_time` TEXT,
  `start_date` VARCHAR(10),
  `end_date` VARCHAR(10),
  `start_date_time_tz` VARCHAR(255),
  `end_date_time_tz` VARCHAR(255),
  `origin_updated_at` TEXT,
  `etag` VARCHAR(255),
  `title` VARCHAR(255),
  `description` VARCHAR(255),
  `content` TEXT,
  `attendees` TEXT,
  `recurrence` TEXT,
  `recurrence_exception` INTEGER,
  `declined` INTEGER,
  `read_only` INTEGER,
  `hidden` INTEGER,
  `url` VARCHAR(255),
  `meeting_status` VARCHAR(255),
  `meeting_url` VARCHAR(255),
  `meeting_icon` VARCHAR(255),
  `meeting_solution` VARCHAR(100),
  `color` VARCHAR(10),
  `calendar_color` VARCHAR(10),
  `task_id` UUID,
  `fingerprints` TEXT,
  `remote_updated_at` TEXT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT,
  `until_date_time` TEXT,
  `recurrence_exception_delete` INTEGER,
  `recurrence_sync_retry` INTEGER
)
    ''');
    await txn.execute('CREATE INDEX IF NOT EXISTS events_end_date ON events(`end_date`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS events_end_time ON events(`end_time`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS events_recurring_id ON events(`recurring_id`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS events_start_date ON events(`start_date`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS events_start_time ON events(`start_time`)');
    await txn.execute('CREATE INDEX IF NOT EXISTS events_task_id ON events(`task_id`)');
  }

  Future<void> _setupList(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS lists(
  `id` UUID PRIMARY KEY,
  `title` VARCHAR(255),
  `icon` VARCHAR(255),
  `color` VARCHAR(255),
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT,
  `sorting` INTEGER,
  `remote_updated_at` TEXT,
  "parentId" UUID,
  `is_folder` INTEGER,
  `system` VARCHAR(255),
  `type` VARCHAR(255)
)
    ''');
  }

  Future<void> _setupMigrations(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS migrations(`name` VARCHAR(255) PRIMARY KEY ,`created_at` TEXT )
    ''');
  }

  Future<void> _setupTasks(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS tasks(
  `id` UUID PRIMARY KEY,
  `title` VARCHAR(255),
  `date` TEXT,
  `datetime` TEXT,
  `recurring_id` UUID,
  `recurrence` TEXT,
  `description` TEXT,
  `origin_id` TEXT,
  `search_text` VARCHAR(255),
  `links` TEXT,
  `status` TINYINT,
  `done` INTEGER,
  `done_at` TEXT,
  `duration` INT,
  `priority` TINYINT,
  `important` INTEGER,
  `list_id` UUID,
  `content` TEXT,
  `location` TEXT,
  `attendees` TEXT,
  `read_at` TEXT,
  `created_at` TEXT,
  `updated_at` TEXT,
  `deleted_at` TEXT,
  `daily_goal` INTEGER,
  `origin` TEXT,
  `remote_updated_at` TEXT,
  `section_id` UUID,
  `sorting` INTEGER,
  `sorting_label` INTEGER,
  `due_date` TEXT
)
    ''');
  }
}
