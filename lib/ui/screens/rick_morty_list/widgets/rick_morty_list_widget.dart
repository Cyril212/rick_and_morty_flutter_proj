import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';

class RickMortyListWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  RickMortyListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: const Key("RickMortyListWidgetKey"),
      child: BlocConsumer<RickMortyListVM, CharacterListEvent>(listener: (context, characterListEvent) {
        final rickMortyVM = context.read<RickMortyListVM>();

        switch (characterListEvent.state) {
          case CharacterListState.idle:
            break;
          case CharacterListState.loading:
            break;
          case CharacterListState.success:
            context.read<RickMortyListVM>().isFetching = false;
            break;
          case CharacterListState.empty:
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            break;
          case CharacterListState.error:
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            rickMortyVM.isFetching = false;
            break;
        }
      }, builder: (BuildContext context, snapshot) {
        final rickMortyVM = context.read<RickMortyListVM>();

        if (snapshot.state == CharacterListState.idle || snapshot.state == CharacterListState.loading && (rickMortyVM.characterList.isEmpty)) {
          return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator());
        } else if (snapshot.state == CharacterListState.empty) {
          return const Center(child: Text("There's no character by your preference :("));
        } else if (snapshot.state == CharacterListState.error) {
          return const Center(child: Text("Oops there's an error"));
        }

        return ListView.separated(
          controller: _scrollController
            ..addListener(() {
              bool shouldFetch = _scrollController.offset == _scrollController.position.maxScrollExtent &&
                  !rickMortyVM.isFetching &&
                  rickMortyVM.isSearchPhraseEmpty &&
                  !rickMortyVM.isFavouriteState;

              if (shouldFetch) {
                context.read<RickMortyListVM>()
                  ..isFetching = true
                  ..fetchCharacterList();

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("loading")));
              }
            }),
          itemBuilder: (context, index) => CharacterCardWidget(character: rickMortyVM.characterList[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemCount: rickMortyVM.characterList.length,
        );
      }),
    );
  }
}
