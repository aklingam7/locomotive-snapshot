import "package:flutter/material.dart";

class AlertDialogW extends StatelessWidget {
  const AlertDialogW({
    required this.title,
    this.body,
    this.content,
    this.actions,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? body;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    assert(body == null || content == null);
    return AlertDialog(
      title: Text(title),
      content: body != null ? Text(body!) : content,
      actions: actions,
      elevation: 18,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
