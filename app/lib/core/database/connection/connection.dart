import 'package:drift/drift.dart';
import 'native.dart' if (dart.library.js_interop) 'web.dart' as impl;

QueryExecutor openConnection() => impl.openConnection();
