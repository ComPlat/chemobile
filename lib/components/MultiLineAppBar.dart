import 'package:chemobile/components/header_with_subtitle.dart';
import 'package:flutter/material.dart';

class MultiLineAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Widget? leading;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const MultiLineAppBar(
      {Key? key, this.leading, required this.title, this.subtitle, this.actions = const []})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: HeaderWithSubtitle(
        title: title,
        subtitle: subtitle,
      ),
      actions: actions.isEmpty ? [hiddenButtonForAlignmentPurposes(context)] : actions,
    );
  }

  IconButton hiddenButtonForAlignmentPurposes(context) {
    return IconButton(
      icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.primary),
      onPressed: null,
    );
  }
}
