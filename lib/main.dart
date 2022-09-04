// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:async' show Future;
import 'package:dict/pages/home.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/objectbox.dart';

void main() => runApp(const ProviderScope(child: App()));

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dict',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x0F085D84),
        ),
      ),
      home: const HomePage(),
    );
  }
}

@Entity()
@Sync()
class Data {
  final String eng, swe, type, lvl;
  const Data(this.eng, this.swe, this.type, this.lvl);
}

class Collection {
  final List<Data> items;
  final int length;
  const Collection(this.items, this.length);

  static Future<Collection> fromCSV(String path) async {
    final _items = <Data>[];
    final data = await rootBundle.load(path);
    final str = utf8.decode(data.buffer.asUint8List());

    int length = 0;
    final lines = str.split('\n');
    for (final line in lines) {
      final List<String> data = line.split(';');
      length++;
      _items.add(Data(data[0], data[3], data[1], data[2]));
    }

    return Collection(_items, length);
  }

  factory Collection.empty() => const Collection([], 0);
}

Future<List<String>> readFile(String path) async {
  final _items = <String>[];
  final bdata = await rootBundle.load('assets/$path');
  final str = utf8.decode(bdata.buffer.asUint8List());

  final lines = str.split('\n');
  for (final line in lines) {
    _items.add(line);
  }
  return _items;
}

class Tuple2<T, U> {
  final T first;
  final U second;

  Tuple2(this.first, this.second);
}

class Tuple3<T, U, V> {
  final T first;
  final U second;
  final V third;

  Tuple3(this.first, this.second, this.third);
}

class Tuple4<A, B, C, D> {
  final A first;
  final B second;
  final C third;
  final D fourth;

  Tuple4(this.first, this.second, this.third, this.fourth);
}
