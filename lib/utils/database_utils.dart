import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  static const _databaseName = 'local.db';

  DatabaseUtils();

  static Future<Database> open() async {
    var databsePath = await getDatabasesPath();
    var path = join(databsePath, _databaseName);

    await Directory(dirname(path)).create(recursive: true);

    Database database = await openDatabase(_databaseName);

    print("database opened at $path, starting setup");

    await _setup(database);

    print("database setup completed");

    return database;
  }

  static Future<void> _setup(Database database) async {
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

  static Future<void> _setupAccounts(txn) async {
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
  `local_details` TEXT,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `remote_updated_at` DATETIME,
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

  static Future<void> _setupCalendars(txn) async {
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
  `remote_updated_at` DATETIME,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME
)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS calendars_akiflow_primary ON calendars(`akiflow_primary`)
    ''');
  }

  static Future<void> _setupContacts(txn) async {
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
  `sorting` DATETIME,
  `origin_updated_at` DATETIME,
  `remote_updated_at` DATETIME,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME
)
    ''');
    await txn.execute('''
      CREATE INDEX IF NOT EXISTS contacts_search_text ON contacts(`search_text`)
    ''');
  }

  static Future<void> _setupDocs(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS docs(
  `id` UUID PRIMARY KEY,
  `connector_id` VARCHAR(50),
  `origin_id` VARCHAR(255),
  `accountId` VARCHAR(100),
  `origin_account_id` VARCHAR(50),
  `origin_updated_at` DATETIME,
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
  `sorting` DATETIME,
  `usages` INT,
  `last_usage_at` DATETIME,
  `pinned` INTEGER,
  `hidden` INTEGER,
  `custom_index1` INT,
  `custom_index2` INT,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `remote_updated_at` DATETIME
)
    ''');
    await txn.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS docs_connector_id_origin_id ON docs(`connector_id`,`origin_id`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_custom_index1 ON docs(`custom_index1`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_important ON docs(`important`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_priority ON docs(`priority`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS docs_search_text ON docs(`search_text`)');
    await txn
        .execute('CREATE INDEX IF NOT EXISTS docs_sorting ON docs(`sorting`)');
    await txn
        .execute('CREATE INDEX IF NOT EXISTS docs_task_id ON docs(`task_id`)');
    await txn
        .execute('CREATE INDEX IF NOT EXISTS docs_usages ON docs(`usages`)');
  }

  static Future<void> _setupEventModifiers(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS event_modifiers(
  `id` UUID PRIMARY KEY,
  `akiflow_account_id` UUID,
  `event_id` UUID,
  `calendar_id` UUID,
  `action` VARCHAR(255),
  `content` TEXT,
  `processed_at` DATETIME,
  `failed_at` DATETIME,
  `result` TEXT,
  `attempts` INT,
  `remote_updated_at` DATETIME,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME
)
    ''');
  }

  static Future<void> _setupEvents(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS events(
  `id` UUID PRIMARY KEY,
  `origin_id` VARCHAR(255),
  `customorigin_id` VARCHAR(255),
  `connector_id` VARCHAR(50),
  `accountId` VARCHAR(100),
  `akiflow_account_id` UUID,
  `origin_account_id` VARCHAR(50),
  `recurring_id` UUID,
  `origin_recurring_id` VARCHAR(255),
  `calendar_id` VARCHAR(255),
  `origincalendar_id` VARCHAR(255),
  `creator_id` VARCHAR(255),
  `organizer_id` VARCHAR(255),
  `original_start_time` DATETIME,
  `original_start_date` VARCHAR(10),
  `start_time` DATETIME,
  `end_time` DATETIME,
  `start_date` VARCHAR(10),
  `end_date` VARCHAR(10),
  `start_date_time_tz` VARCHAR(255),
  `end_date_time_tz` VARCHAR(255),
  `origin_updated_at` DATETIME,
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
  `remote_updated_at` DATETIME,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `until_date_time` DATETIME,
  `recurrence_exception_delete` INTEGER,
  `recurrence_sync_retry` INTEGER
)
    ''');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_end_date ON events(`end_date`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_end_time ON events(`end_time`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_recurring_id ON events(`recurring_id`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_start_date ON events(`start_date`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_start_time ON events(`start_time`)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS events_task_id ON events(`task_id`)');
  }

  static Future<void> _setupList(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS lists(
  `id` UUID PRIMARY KEY,
  `title` VARCHAR(255),
  `icon` VARCHAR(255),
  `color` VARCHAR(255),
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `sorting` DATETIME,
  `remote_updated_at` DATETIME,
  "parentId" UUID,
  `is_folder` INTEGER,
  `system` VARCHAR(255),
  `type` VARCHAR(255)
)
    ''');
  }

  static Future<void> _setupMigrations(txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS migrations(`name` VARCHAR(255) PRIMARY KEY ,`created_at` DATETIME )
    ''');
  }

  static Future<void> _setupTasks(txn) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS tasks(
  `id` UUID PRIMARY KEY,
  `title` VARCHAR(255),
  `date` DATETIME,
  `date_time` DATETIME,
  `recurring_id` UUID,
  `recurrence` TEXT,
  `description` TEXT,
  `search_text` VARCHAR(255),
  `links` TEXT,
  `status` TINYINT,
  `done` INTEGER,
  `done_at` DATETIME,
  `duration` INT,
  `priority` TINYINT,
  `sorting` DATETIME,
  `important` INTEGER,
  `list_id` UUID,
  `content` TEXT,
  `location` TEXT,
  `attendees` TEXT,
  `read_at` DATETIME,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `daily_goal` DATETIME,
  `origin` DATETIME,
  `remote_updated_at` DATETIME,
  `section_id` UUID,
  `sorting_label` INTEGER,
  `due_date` DATETIME
)
    ''');
  }
}
