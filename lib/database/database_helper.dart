import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // 单例实例
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // 命名构造函数（私有）
  DatabaseHelper._internal(); // 这是正确的私有构造函数写法

  // 工厂构造函数返回单例
  factory DatabaseHelper() => _instance;

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDB() async {
    final dbPath = join(await getDatabasesPath(), 'sports_db.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
      onUpgrade: _onUpgrade,
    );
  }

  // 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE IF NOT EXISTS players (
        uuid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        sex TEXT NOT NULL CHECK(sex IN ('male', 'female', 'others')),
        brief TEXT,
        organization TEXT,
        avatar TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS shot_data_template (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_uuid TEXT NOT NULL,
        player_uuid TEXT NOT NULL,
        record_time TEXT NOT NULL,
        shot_time INTEGER NOT NULL,
        ball TEXT NOT NULL CHECK(ball IN ('red', 'yellow', 'green', 'brown', 'blue', 'pink', 'black')),
        shot_result TEXT NOT NULL CHECK(shot_result IN ('pot', 'miss', 'fault')),
        score INTEGER NOT NULL,
        FOREIGN KEY (match_uuid) REFERENCES matches(uuid),
        FOREIGN KEY (player_uuid) REFERENCES players(uuid)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS career_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_uuid TEXT,
        
        total_match INTEGER NOT NULL DEFAULT 0,
        total_frame INTEGER NOT NULL DEFAULT 0,
        win_matches INTEGER NOT NULL DEFAULT 0,
        win_frames INTEGER NOT NULL DEFAULT 0,
        frame_win_rate REAL NOT NULL DEFAULT 0,
        match_win_rate REAL NOT NULL DEFAULT 0,
        
        shots_count INTEGER NOT NULL DEFAULT 0,
        pots_count INTEGER NOT NULL DEFAULT 0,
        pot_success_rate REAL NOT NULL DEFAULT 0,
        total_score INTEGER NOT NULL DEFAULT 0,
        frame_time INTEGER NOT NULL DEFAULT 0,
        fault_count INTEGER NOT NULL DEFAULT 0,
        break_ INTEGER NOT NULL DEFAULT 0,
        highest_break INTEGER NOT NULL DEFAULT 0,
        centuries INTEGER NOT NULL DEFAULT 0,
        plus50 INTEGER NOT NULL DEFAULT 0,
        plus30 INTEGER NOT NULL DEFAULT 0,
        plus20 INTEGER NOT NULL DEFAULT 0,
        plus10 INTEGER NOT NULL DEFAULT 0,
        average_shot_time REAL NOT NULL DEFAULT 0,
        max_shot_time REAL NOT NULL DEFAULT 0,
                       
        fault_counts TEXT NOT NULL DEFAULT '[]',
        balls_shot_counts TEXT NOT NULL DEFAULT '[]',
        balls_pot_counts TEXT NOT NULL DEFAULT '[]',
        pot_success_counts TEXT NOT NULL DEFAULT '[]',        
        FOREIGN KEY (player_uuid) REFERENCES players (uuid) ON DELETE CASCADE
      );
    ''');

    // 其他表创建语句...
  }

  Future<void> _onOpen(Database db) async {
    // 在数据库打开时强制重建 players 表（谨慎使用！）
    print('On Database Open!');

    // debug
    // await db.execute('''DROP TABLE IF EXISTS players;''');
    // await db.execute('''DROP TABLE IF EXISTS career_data;''');
    // await db.execute('''DROP TABLE IF EXISTS matches;''');
    final res1 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
    );
    print('wtf $res1');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS players (
        uuid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        sex TEXT NOT NULL CHECK(sex IN ('male', 'female', 'others')),
        brief TEXT,
        organization TEXT,
        avatar TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS shot_data_template (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_uuid TEXT NOT NULL,
        player_uuid TEXT NOT NULL,
        record_time TEXT NOT NULL,
        shot_time INTEGER NOT NULL,
        ball TEXT NOT NULL CHECK(ball IN ('red', 'yellow', 'green', 'brown', 'blue', 'pink', 'black')),
        shot_result TEXT NOT NULL CHECK(shot_result IN ('pot', 'miss', 'fault')),
        score INTEGER NOT NULL,
        frame_index INTEGER NOT NULL,
        FOREIGN KEY (match_uuid) REFERENCES matches(uuid),
        FOREIGN KEY (player_uuid) REFERENCES players(uuid)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS career_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_uuid TEXT,
        
        total_match INTEGER NOT NULL DEFAULT 0,
        total_frame INTEGER NOT NULL DEFAULT 0,
        win_matches INTEGER NOT NULL DEFAULT 0,
        win_frames INTEGER NOT NULL DEFAULT 0,
        frame_win_rate REAL NOT NULL DEFAULT 0,
        match_win_rate REAL NOT NULL DEFAULT 0,
        
        shots_count INTEGER NOT NULL DEFAULT 0,
        pots_count INTEGER NOT NULL DEFAULT 0,
        pot_success_rate REAL NOT NULL DEFAULT 0,
        total_score INTEGER NOT NULL DEFAULT 0,
        frame_time INTEGER NOT NULL DEFAULT 0,
        fault_count INTEGER NOT NULL DEFAULT 0,
        break_ INTEGER NOT NULL DEFAULT 0,
        highest_break INTEGER NOT NULL DEFAULT 0,
        centuries INTEGER NOT NULL DEFAULT 0,
        plus50 INTEGER NOT NULL DEFAULT 0,
        plus30 INTEGER NOT NULL DEFAULT 0,
        plus20 INTEGER NOT NULL DEFAULT 0,
        plus10 INTEGER NOT NULL DEFAULT 0,
        average_shot_time REAL NOT NULL DEFAULT 0,
        max_shot_time REAL NOT NULL DEFAULT 0,

        fault_counts TEXT NOT NULL DEFAULT '[]',
        balls_shot_counts TEXT NOT NULL DEFAULT '[]',
        balls_pot_counts TEXT NOT NULL DEFAULT '[]',
        pot_success_counts TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (player_uuid) REFERENCES players (uuid) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        create_time TEXT NOT NULL,
        players TEXT NOT NULL DEFAULT '[]',
        alpha_players TEXT NOT NULL DEFAULT '[]',
        beta_players TEXT NOT NULL DEFAULT '[]',
        win_record TEXT NOT NULL DEFAULT '[]',
        alpha_score INTEGER NOT NULL DEFAULT 0,
        beta_score INTEGER NOT NULL DEFAULT 0,
        frame_count INTEGER NOT NULL DEFAULT 0
      );
    ''');
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
    );
    print('wtf $res');
  }

  // 数据库升级回调
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 版本迁移逻辑
  }

  // 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}