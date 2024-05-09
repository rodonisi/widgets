import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:widgets/providers/cards_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    HomeWidget.setAppGroupId("group.com.rileytestut.AltStore.9LLQNF6L4W");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const CardsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context, builder: (context) => const AddDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddDialog extends ConsumerStatefulWidget {
  const AddDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDialogState();
}

class _AddDialogState extends ConsumerState<AddDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final contents = [
    const FlutterLogo(),
    const Icon(Icons.ac_unit),
    const Icon(Icons.access_alarm),
    const Icon(Icons.zoom_out),
    const Icon(Icons.zoom_in),
    const Icon(Icons.zoom_out_map),
    const Icon(Icons.zoom_out_map_sharp),
    const Icon(
      Icons.icecream,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Card'),
      content: TextField(
        controller: controller,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            ref.read(cardsProvider.notifier).addCard(
                  name: controller.text,
                  content: contents[
                      ref.read(cardsProvider).length % contents.length],
                );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        )
      ],
    );
  }
}

class CardsList extends ConsumerWidget {
  const CardsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider);

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(cards[index].name),
        );
      },
    );
  }
}
