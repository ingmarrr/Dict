import 'dart:io';

import 'package:dict/controllers/notifiers.dart';
import 'package:dict/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final languageController = ChangeNotifierProvider<Controller<String>>(
  (_) => Controller<String>(init: 'english'),
);

final wordsController = ChangeNotifierProvider<Controller<List<String>>>(
  (_) => Controller<List<String>>(init: []),
);

class HomePage extends ConsumerWidget {
  static const String id = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    final lang = ref.watch(languageController);
    final words = ref.watch(wordsController);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.state,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Container(
        height: mq.size.height,
        width: mq.size.width,
        padding: const EdgeInsets.all(15),
        color: Theme.of(context).colorScheme.background,
        child: Stack(
          children: [
            Positioned(
              left: 300,
              child: SizedBox(
                // color: Colors.red.shade400.withOpacity(.3),
                width: mq.size.width - 300,
                height: mq.size.height,
                child: ListView.builder(
                  controller: ScrollController(),
                  itemCount: words.state.length,
                  itemBuilder: (context, idx) => Container(
                    height: 30,
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.all(3),
                    color: Colors.green.shade400.withOpacity(.2),
                    child: Center(
                      child: Text(
                        words.state[idx],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Home(),
          ],
        ),
      ),
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  Future<List<String>> langNames() async {
    final langs = await readFile('_info.csv');
    return langs.map((e) => e.split('.')[0]).toList();
  }

  Future<List<String>> words(WidgetRef ref) async {
    final lang = ref.watch(languageController);
    final words = await readFile('${lang.state}.csv');
    return words;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final wordsState = ref.watch(wordsController);
      wordsState.state = await words(ref);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageController);

    return FutureBuilder<List<String>>(
      future: langNames(),
      initialData: const <String>[],
      builder: (context, snapshot) => Container(
        width: 300,
        child: ListView.builder(
          controller: ScrollController(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, idx) => Container(
            height: 30,
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(3),
            color: Colors.blue.shade400.withOpacity(.2),
            child: InkWell(
              onTap: () async {
                lang.state = snapshot.data![idx];
                ref.read(wordsController).state = await words(ref);
              },
              child: Center(
                child: Text(snapshot.data![idx]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LearningPage extends StatelessWidget {
  const LearningPage({
    Key? key,
    required this.pageController,
    required this.mq,
  }) : super(key: key);

  final PageController pageController;
  final MediaQueryData mq;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(title: const Text('Dict')),
      body: Center(
        child: FutureBuilder<Collection>(
          future: Collection.fromCSV('assets/swedish.csv'),
          initialData: Collection.empty(),
          builder: (context, snapshot) => Stack(children: [
            Positioned(
              bottom: 20,
              right: 20,
              child: IconButton(
                onPressed: () => pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInCubic,
                ),
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: IconButton(
                onPressed: () => pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInCubic,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Positioned(
              top: 0,
              child: SizedBox(
                height: mq.size.height - 150,
                width: mq.size.width,
                child: DataPage(snapshot, pageController),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class DataPage extends StatefulHookConsumerWidget {
  final AsyncSnapshot<Collection> snapshot;
  final PageController controller;

  const DataPage(this.snapshot, this.controller, {Key? key}) : super(key: key);

  @override
  ConsumerState<DataPage> createState() => DataPageState();
}

class DataPageState extends ConsumerState<DataPage> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:
          widget.snapshot.data != null ? widget.snapshot.data!.length : 0,
      itemBuilder: (ctx, idx) => Card(
        color: Theme.of(context).colorScheme.secondary,
        child: FlipCard(
          widget.snapshot.data!.items[idx],
          controller: widget.controller,
        ),
      ),
    );
  }
}

class FlipCard extends ConsumerStatefulWidget {
  final Data data;
  final PageController controller;

  const FlipCard(this.data, {required this.controller, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlipCardState();
}

class _FlipCardState extends ConsumerState<FlipCard> {
  final answeredController = ChangeNotifierProvider((_) => BoolController());

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(answeredController);
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (val) {
        final name = val.physicalKey.debugName!.toUpperCase();

        if (name == 'ARROW RIGHT') {
          widget.controller.nextPage(
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeInCubic);
          state.state = false;
        }
        if (name == 'ARROW LEFT') {
          widget.controller.previousPage(
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeInCubic);
          state.state = false;
        }
        if (name == 'ARROW UP') {
          state.state = true;
        }
        if (name == 'ARROW DOWN') {
          state.state = false;
        }
      },
      child: ListTile(
        leading: Text(state.state ? 'Swedish' : 'English'),
        title: Text(widget.data.eng),
        subtitle: state.state ? Text(widget.data.swe) : const Text(''),
        onTap: () => state.toggle(),
        textColor: state.state ? Colors.white : null,
        tileColor: state.state
            ? Colors.blue.shade800
            : Theme.of(context).colorScheme.primaryContainer,
        // hoverColor: Colors.blue.shade800,
      ),
    );
  }
}

class DataColumn extends StatelessWidget {
  final AsyncSnapshot<Collection> snapshot;

  const DataColumn(
    this.snapshot, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (ctx, idx) => ListTile(
        title: Text(snapshot.data!.items[idx].eng),
        subtitle: Text(snapshot.data!.items[idx].swe),
      ),
    );
  }
}
