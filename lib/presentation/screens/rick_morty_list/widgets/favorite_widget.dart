import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class FavoriteWidget extends StatefulWidget {
  final int characterId;
  final Function(bool) onFavouriteClick;

  bool isChosen;

  FavoriteWidget({Key? key, required this.characterId, required this.onFavouriteClick, this.isChosen = false}) : super(key: key);

  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  void _updateWidgetState() {
    widget.isChosen = !widget.isChosen;

    widget.onFavouriteClick(widget.isChosen);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.amber,
      icon: widget.isChosen ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
      onPressed: () {
        setState(_updateWidgetState);
      },
    );
  }
}