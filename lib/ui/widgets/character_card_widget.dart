import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class CharacterCardWidget extends StatelessWidget {
  final Character character;
  final bool horizontal;

  const CharacterCardWidget({Key? key, required this.character, this.horizontal = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: Hero(
        tag: "planet-hero-${character.id}",
        child: CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage(
            character.image,
          ),
        ),
      ),
    );

    final planetCardContent = Container(
      margin: EdgeInsets.fromLTRB(horizontal ? 76.0 : 16.0, horizontal ? 8.0 : 42.0, 16.0, 16.0),
      constraints: const BoxConstraints.expand(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: horizontal ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Container(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Name: ${character.name}",
                          textAlign: horizontal ? TextAlign.start : TextAlign.center,
                          overflow: TextOverflow.visible,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 10.0),
                  Text("Gender: ${character.gender}"),
                  Container(height: 10.0),
                  Text("Birth: ${DateFormat.yMd().format(DateTime.parse(character.created))}"),
                  Container(height: 10.0),
                  if (!horizontal)
                    Expanded(
                      flex: 2,
                      child: FavoriteWidget(
                        key: UniqueKey(),
                        isChosen: character.isFavourite,
                        characterId: character.id,
                      ),
                    )
                ],
              )),
          if (horizontal) const Spacer(),
          if (horizontal)
            Expanded(
              flex: 2,
              child: FavoriteWidget(
                key: UniqueKey(),
                isChosen: character.isFavourite,
                characterId: character.id,
              ),
            )
          // Icon(Icons.favorite,color: Colors.amber,)
        ],
      ),
    );

    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 134.0 : 170.0,
      margin: horizontal ? const EdgeInsets.only(left: 46.0) : const EdgeInsets.only(top: 72.0),
      decoration: BoxDecoration(
        color: const Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    return GestureDetector(
        onTap: horizontal
            ? () {
                context.read<RickMortyListVM>()
                  ..currentCharacterId = character.id
                  ..moveToDetailScreen(context);
              }
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          child: Stack(
            children: <Widget>[
              planetCard,
              planetThumbnail,
            ],
          ),
        ));
  }
}

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
