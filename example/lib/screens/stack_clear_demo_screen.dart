import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

class StackClearDemoScreen extends StatefulWidget {
  const StackClearDemoScreen({super.key});

  @override
  State<StackClearDemoScreen> createState() => _StackClearDemoScreenState();
}

class _StackClearDemoScreenState extends State<StackClearDemoScreen> {
  List<String> _stackSnapshot = [];

  @override
  void initState() {
    super.initState();
    _refreshStack();
    FFRNavigator.I.addListener(_refreshStack);
  }

  @override
  void dispose() {
    FFRNavigator.I.removeListener(_refreshStack);
    super.dispose();
  }

  void _refreshStack() {
    setState(() {
      _stackSnapshot = FFRNavigator.I.stack.map((m) => m.originalUrl).toList();
    });
  }

  void _clearStackAndRestart() {
    FFRNavigator.I.popAll();
  }

  void _clearStackAndPushHome() {
    FFRNavigator.I.setNewRoutePath('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack Clear Demo'),
        leading: BackButton(onPressed: () => FFRNavigator.I.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilha de navegação atual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: _stackSnapshot.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Pilha vazia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stackSnapshot.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final isTop = index == _stackSnapshot.length - 1;
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(_stackSnapshot[index]),
                          trailing: isTop
                              ? const Chip(label: Text('topo'))
                              : null,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ao limpar a pilha, o app não tem para onde voltar. '
              'O roteador detecta a pilha vazia e navega automaticamente '
              'para a rota inicial, reiniciando o fluxo do app.',
              style: TextStyle(color: Colors.black54),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _clearStackAndRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpar pilha e reiniciar app'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _clearStackAndPushHome,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpar pilha e navegar para home'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
