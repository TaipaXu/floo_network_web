import 'package:flutter/material.dart';
import '/models/connection.dart' as model;

class NavButton extends StatelessWidget {
  final model.Connection connection;
  final bool active;
  final void Function()? onClick;
  const NavButton(
      {super.key, required this.connection, this.active = false, this.onClick});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: onClick,
        child: Container(
          width: double.infinity,
          color: active
              ? Theme.of(context).primaryColor
              : const Color.fromARGB(31, 70, 70, 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                connection.ip,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.white : Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
