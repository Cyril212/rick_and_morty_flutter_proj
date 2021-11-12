import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class FilterModeWidget extends StatefulWidget {
  bool isChoosen = false;

  FilterModeWidget({Key? key, this.isChoosen = false}) : super(key: key);

  @override
  _FilterModeWidgetState createState() => _FilterModeWidgetState();
}

class _FilterModeWidgetState extends State<FilterModeWidget> {

  @override
  void didUpdateWidget(covariant FilterModeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.isChoosen != widget.isChoosen){
      widget.isChoosen = context.read<RickMortyListVM>().isBasic == false;
    }

  }
  @override
  void initState() {
    super.initState();
    widget.isChoosen = context.read<RickMortyListVM>().isBasic == false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          setState(() {
            widget.isChoosen = !widget.isChoosen;
            context.read<RickMortyListVM>().setListMode(widget.isChoosen);
          });
        },
        icon: Icon(
          widget.isChoosen ? Icons.favorite : Icons.favorite_border,
          color: Colors.amber,
        ));
  }
}
