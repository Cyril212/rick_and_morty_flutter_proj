import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class FavoriteWidget extends StatefulWidget {
  final int characterId;
  bool isChosen;
  bool shouldRefreshList;

  FavoriteWidget({Key? key, this.isChosen = false, required this.characterId, this.shouldRefreshList = false}) : super(key: key);

  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  void _setFavouriteState() {
    final rickMortyListVM = context.read<RickMortyListVM>();

    rickMortyListVM.setFavouriteCharacterState(widget.characterId, widget.isChosen);
    rickMortyListVM.updateList();
  }

  void _updateWidgetState() {
    widget.isChosen = !widget.isChosen;

    _setFavouriteState();
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