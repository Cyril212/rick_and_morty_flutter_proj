import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: kColorDarkPurple,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [ BoxShadow(
              color: kColorBlack26,
              blurRadius: 5,
              // Shadow position
            ), ],
            border: Border.all(
                width: 1, color: kColorDarkPurple, style: BorderStyle.solid)),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.search, color: kColorAmber,),
            ),
            Expanded(
              child: TextField(
                onChanged: (searchPhrase){
                  context.read<RickMortyListVM>().updateCharacterListBySearchPhrase(searchPhrase);
                },
                decoration: const InputDecoration(
                  hintText: 'Type a character name',
                  hintStyle: kHintTextStyle,
                  border: InputBorder.none,
                ),
                style: kPrimaryTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
