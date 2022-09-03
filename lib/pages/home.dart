import 'package:dict/controllers/notifiers.dart';
import 'package:dict/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends ConsumerWidget {
  static const String id = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(title: const Text('Dict')),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: mq.size.width * .05,
            vertical: mq.size.height * .05,
          ),
          child: FutureBuilder<Collection>(
            future: Collection.fromCSV('assets/3k.csv'),
            initialData: Collection.empty(),
            builder: (context, snapshot) => Stack(children: [
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: DataPage(snapshot),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class DataPage extends StatefulHookConsumerWidget {
  final AsyncSnapshot<Collection> snapshot;

  const DataPage(this.snapshot, {Key? key}) : super(key: key);

  @override
  ConsumerState<DataPage> createState() => DataPageState();
}

class DataPageState extends ConsumerState<DataPage> {
  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return PageView.builder(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:
          widget.snapshot.data != null ? widget.snapshot.data!.length : 0,
      itemBuilder: (ctx, idx) => Card(
        color: Theme.of(context).colorScheme.secondary,
        child: FlipCard(
          widget.snapshot.data!.items[idx],
          controller: pageController,
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
