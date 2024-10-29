import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/todo_model.dart';

//lớp định nghĩa các route
class TodoRouter {
  //ds các cv được qly bởi backend
  final _todos = <TodoModel>[];

// tạo và trả về 1 router cho các hđ
  Router get router {
    final router = Router();

    //
    router.get('/todos', _getTodosHandler);

    //endpoint
    router.post('/todos', _addTodoHandler);

    //endpoint xóa
    router.delete('/todos<id>', _deleteTodoHandler);

    //endpoint cập nhat
    router.put('/todos/<id>', _updateTodoHandler);

    return router;
  }

//
  static final _headers = {'Content-Type': 'application/json'};

//
  Future<Response> _getTodosHandler(Request req) async {
    try {
      final body = json.encode(_todos.map((todo) => todo.toMap()).toList());
      return Response.ok(
        body,
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  /// xử lý
  Future<Response> _addTodoHandler(Request req) async {
    try {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final todo = TodoModel.fromMap(data);
      _todos.add(todo);
      return Response.ok(
        todo.toJson(),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  //xử lý yêu cầu xóa
  Future<Response> _deleteTodoHandler(Request req, String id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == int.parse(id));
      if (index == -1) {
        return Response.notFound('không tìm thấy todo có id - $id');
      }

      final removedTodo = _todos.removeAt(index);
      return Response.ok(
        removedTodo.toJson(),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }

//xử lý yeu càu cập nhật
  Future<Response> _updateTodoHandler(Request req, String id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == int.parse(id));
      if (index == -1) {
        return Response.notFound('không tìm thấy todo có id - $id');
      }
      final payload = await req.readAsString();
      final map = json.decode(payload);
      final updatedTodo = TodoModel.fromMap(map);

      _todos[index] = updatedTodo;
      return Response.ok(
        updatedTodo.toJson(),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }
}
