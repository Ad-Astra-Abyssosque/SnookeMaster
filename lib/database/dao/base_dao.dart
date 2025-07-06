

import '../database_helper.dart';

abstract class BaseDao<T> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  String get tableName;

  String get primaryKey => 'id'; // 默认主键名，可被子类覆盖

  T fromMap(Map<String, dynamic> map);

  Map<String, dynamic> toMap(T entity);

  Future<int> insert(T entity) async {
    final db = await dbHelper.database;
    return db.insert(tableName, toMap(entity));
  }

  Future<List<T>> queryAll() async {
    final db = await dbHelper.database;
    final maps = await db.query(tableName);
    return maps.map(fromMap).toList();
  }

  // Future<T?> findById(dynamic id) async {
  //   final db = await dbHelper.database;
  //   final maps = await db.query(
  //     tableName,
  //     where: '$primaryKey = ?',
  //     whereArgs: [id],
  //     limit: 1,
  //   );
  //
  //   return maps.isEmpty ? null : fromMap(maps.first);
  // }
  //
  Future<List<T>> queryWhere(
      String where,
      List<dynamic> whereArgs, { // 改为必需参数
        String? orderBy,
        int? limit,
      }) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs, // 使用传入的参数
      orderBy: orderBy,
      limit: limit,
    );
    return maps.map(fromMap).toList();
  }

  // 更新 ========================================
  Future<int> update(T entity) async {
    final db = await dbHelper.database;
    final map = toMap(entity);
    final id = map[primaryKey];

    return await db.update(
      tableName,
      map,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
  }

  // 删除 ========================================
  Future<int> delete(dynamic id) async {
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
  }

  // Future<int> deleteWhere(String where, {List<dynamic>? whereArgs}) async {
  //   final db = await dbHelper.database;
  //   return await db.delete(
  //     tableName,
  //     where: where,
  //     whereArgs: whereArgs,
  //   );
  // }
  //
  // Future<int> deleteAll() async {
  //   final db = await dbHelper.database;
  //   return await db.delete(tableName);
  // }

// 其他通用CRUD方法...
}