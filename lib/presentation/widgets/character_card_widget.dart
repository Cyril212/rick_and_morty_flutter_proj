import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/widgets/favorite_widget.dart';

class CharacterCardWidget extends StatelessWidget {
  final Character character;
  final bool horizontal;

  final VoidCallback? onClick;
  final Function(bool) onFavoriteClick;

  const CharacterCardWidget({Key? key, required this.character, this.horizontal = true, this.onClick, required this.onFavoriteClick})
      : super(key: key);

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
                        onFavouriteClick: onFavoriteClick,
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
                onFavouriteClick: onFavoriteClick,
              ),
            )
        ],
      ),
    );

    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 134.0 : 170.0,
      margin: horizontal ? const EdgeInsets.only(left: 46.0) : const EdgeInsets.only(top: 72.0),
      decoration: BoxDecoration(
        color: kColorSecondary,
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
            ? onClick
            // () {
            //       ;
            //     // context.read<RickMortyListVM>()
            //     //   ..currentCharacterId = character.id
            //     //   ..moveToDetailScreen(context);
            //   }
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
