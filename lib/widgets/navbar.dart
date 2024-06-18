import 'package:flutter/material.dart';
import '/models/connection.dart' as model;
import '/widgets/navButton.dart' as widget;

class Navbar extends StatelessWidget {
  final List<model.Connection> connections;
  final int activeIndex;
  final void Function(int index)? onClick;
  const Navbar(
      {super.key,
      required this.connections,
      this.activeIndex = -1,
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.NavButton(
          connection: model.Connection(ip: 'My Files'),
          active: activeIndex == 0,
          onClick: () {
            onClick?.call(0);
          },
        ),
        for (int i = 0; i < connections.length; i++)
          widget.NavButton(
            connection: connections[i],
            active: i + 1 == activeIndex,
            onClick: () {
              onClick?.call(i + 1);
            },
          ),
      ],
    );
  }
}
