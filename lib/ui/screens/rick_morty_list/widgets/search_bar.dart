import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF333366),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [ BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              // Shadow position
            ), ],
            border: Border.all(
                width: 1, color: const Color(0xFF333366), style: BorderStyle.solid)),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.search,color: Colors.amber,),
            ),
            Expanded(
              child: TextField(
                onChanged: (searchPhrase){
                  context.read<RickMortyListVM>().updateCharacterListBySearchPhrase(searchPhrase);
                },
                decoration: const InputDecoration(
                  hintText: 'Type a character name',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
