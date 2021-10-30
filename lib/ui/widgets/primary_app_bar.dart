import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/vm/character_list_vm.dart';

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
          Align(alignment: Alignment.centerRight, child: FilterWidget()),
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

class FilterWidget extends StatefulWidget {
  bool isChoosen = false;

  FilterWidget({Key? key, this.isChoosen = false}) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          setState(() {
            widget.isChoosen = !widget.isChoosen;
            context.read<CharacterListVM>().updateCharacterList(widget.isChoosen);
          });
        },
        icon: Icon(
          widget.isChoosen ? Icons.filter_alt : Icons.filter_alt_outlined,
          color: Colors.amber,
        ));
    // return InkWell(
    //     onTap: () {

    //     },
    //     child: Icon(
    //       widget.isChoosen ? Icons.favorite : Icons.favorite_border,
    //       color: Colors.amber,
    //     ));
  }
}
