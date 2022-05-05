import 'package:flutter/material.dart';
import 'package:flutter_data_demo/src/password/password_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordScope extends ConsumerWidget {
  final Widget child;

  const PasswordScope({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PasswordState>(
      passwordControllerProvider,
      (previous, next) => next.whenOrNull(
        requested: () => _showPasswordDialog(context),
      ),
    );

    return child;
  }

  void _showPasswordDialog(BuildContext context) => showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => const _PasswordDialog(),
      );
}

class _PasswordDialog extends ConsumerStatefulWidget {
  const _PasswordDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends ConsumerState<_PasswordDialog> {
  late final TextEditingController _controller;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => Future.value(_completed),
        child: AlertDialog(
          title: const Text('Enter passphrase'),
          content: TextField(
            controller: _controller,
            autocorrect: false,
            enableIMEPersonalizedLearning: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(
              label: Text('Password'),
            ),
            onSubmitted: (_) => _setPassword(context),
          ),
          actions: [
            TextButton(
              onPressed: () => _setPassword(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  void _setPassword(BuildContext context) {
    ref.read(passwordControllerProvider.notifier).setPassword(_controller.text);
    setState(() {
      _completed = true;
    });
    Navigator.of(context).pop();
  }
}
