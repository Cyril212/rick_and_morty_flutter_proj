import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:intl/intl.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/vm/character_list_vm.dart';

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
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: 4.0),
              Text(character.name),
              Container(height: 10.0),
              Text(character.gender),
              Container(height: 10.0),
              Text("Birth: ${DateFormat.yMd().format(character.created).toUpperCase()}"),
            ],
          ),
          Spacer(),
          FavoriteWidget(
            isChoosen: character.isFavourite, characterId: character.id,
          )
          // Icon(Icons.favorite,color: Colors.amber,)
        ],
      ),
    );

    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 124.0 : 154.0,
      margin: horizontal ? const EdgeInsets.only(left: 46.0) : const EdgeInsets.only(top: 72.0),
      decoration: BoxDecoration(
        color: Color(0xFF333366),
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
        onTap: horizontal ? () {} : null,
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
  bool isChoosen = false;

  FavoriteWidget({Key? key, this.isChoosen = false, required this.characterId}) : super(key: key);

  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            widget.isChoosen = !widget.isChoosen;

            context.read<CharacterListVM>().setFavouriteForCharacter(widget.characterId, widget.isChoosen);
          });
        },
        child: Icon(
          widget.isChoosen ? Icons.favorite : Icons.favorite_border,
          color: Colors.amber,
        ));
  }
}
