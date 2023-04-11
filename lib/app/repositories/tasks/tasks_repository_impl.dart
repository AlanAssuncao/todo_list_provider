import 'package:todo_list_provider/app/core/auth/auth_provider.dart';
import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';
import 'package:todo_list_provider/app/models/task_model.dart';

import './tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final SqliteConnectionFactory _sqliteConnectionFactory;
  final AuthProvider _authProvider;

  TasksRepositoryImpl({
    required SqliteConnectionFactory sqliteConnectionFactory,
    required AuthProvider authProvider,
  })  : _sqliteConnectionFactory = sqliteConnectionFactory,
        _authProvider = authProvider;

  @override
  Future<void> save(DateTime date, String description) async {
    final conn = await _sqliteConnectionFactory.openConnection();
    await conn.insert('todo', {
      'id': null,
      'descricao': description,
      'data_hora': date.toIso8601String(),
      'finalizado': 0,
      'usuario': _authProvider.user?.displayName ?? 'Não informado',
    });
  }

/*
select * 
    from todo 
    where data_hora between ? and ? 
    order by data_hora
    and usuario = ?
*/

  @override
  Future<List<TaskModel>> findByPeriod(DateTime start, DateTime end) async {
    final startFilter = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endFilter = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final conn = await _sqliteConnectionFactory.openConnection();
    final result = await conn.rawQuery('''
    select *
    from todo
    where usuario = ?
    and data_hora between ? and ? 
    order by data_hora
    ''', [
      _authProvider.user?.displayName,
      startFilter.toIso8601String(),
      endFilter.toIso8601String()
    ]);
    return result.map((e) => TaskModel.loadFromDB(e)).toList();
  }

  @override
  Future<void> checkOrUncheckTask(TaskModel task) async {
    final conn = await _sqliteConnectionFactory.openConnection();
    final finished = task.finished ? 1 : 0;

    await conn.rawUpdate(
        'update todo set finalizado = ? where id = ?', [finished, task.id]);
  }

  @override
  Future<void> deleteTask(TaskModel task) async {
    final conn = await _sqliteConnectionFactory.openConnection();

    await conn.rawDelete('delete from todo where id = ?', [task.id]);
  }
}
