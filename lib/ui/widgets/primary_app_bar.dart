import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/rick_morty_list/widgets/favourite_mode_widget.dart';

class PrimaryAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const PrimaryAppbar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight - statusBarHeight / 10),
      height: preferredSize.height + statusBarHeight,
      child: Stack(
        children: [
          Align(alignment: Alignment.centerRight, child: FilterModeWidget()),
          Center(
              child: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Schwifty', fontWeight: FontWeight.w600, fontSize: 24.0))),
        ],
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(0.5, 0.0),
            stops: [0.0, 0.5],
            tileMode: TileMode.clamp),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 48);
}