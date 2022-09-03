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
            horizontal: mq.size.width * .1,
            vertical: mq.size.height * .05,
          ),
          child: FutureBuilder<Collection>(
            future: Collection.fromCSV('assets/3k.csv'),
            initialData: Collection.empty(),
            builder: (context, snapshot) => DataPage(snapshot),
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
            ));
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
        }
        if (name == 'ARROW LEFT') {
          widget.controller.previousPage(
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeInCubic);
        }
        if (name == 'ARROW UP') {
          state.state = true;
        }
        if (name == 'ARROW DOWN') {
          state.state = false;
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                child: Text(state.state ? 'Swedish' : 'English',
                    style: Theme.of(context).textTheme.headline4!),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(
                    top: 120, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: state.state
                      ? Colors.blue.shade700.withOpacity(.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: state.state
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                child: InkWell(
                  onTap: () => state.toggle(),
                  child: Center(
                    child: Text(
                      state.state ? widget.data.swe : widget.data.eng,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 40, color: Colors.blue.shade700),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                height: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(.8),
                    borderRadius: BorderRadius.circular(3)
                    // shape: BoxShape.circle,
                    ),
                child: IconButton(
                  onPressed: () => widget.controller.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInCubic,
                  ),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(.8),
                    borderRadius: BorderRadius.circular(3)
                    // shape: BoxShape.circle,
                    ),
                child: IconButton(
                  onPressed: () => widget.controller.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInCubic,
                  ),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ],
        ),
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
