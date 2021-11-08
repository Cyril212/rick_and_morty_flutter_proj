import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';

class RickMortyListWidget extends StatefulWidget {

  const RickMortyListWidget({Key? key}) : super(key: key);

  @override
  State<RickMortyListWidget> createState() => _RickMortyListWidgetState();
}

class _RickMortyListWidgetState extends State<RickMortyListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: const Key("RickMortyListWidgetKey"),
      child: BlocConsumer<RickMortyListVM, CharacterListEvent>(listener: (context, characterListEvent) {
        final rickMortyVM = context.read<RickMortyListVM>();

        switch (characterListEvent.state) {
          case ListState.idle:
            break;
          case ListState.loading:
            break;
          case ListState.success:
            context.read<RickMortyListVM>().isFetching = false;
            break;
          case ListState.empty:
            break;
          case ListState.error:
            rickMortyVM.isFetching = false;
            break;
        }
      }, builder: (BuildContext context, snapshot) {
        final rickMortyVM = context.read<RickMortyListVM>();

        if (snapshot.state == ListState.idle || snapshot.state == ListState.loading && (rickMortyVM.characterList.isEmpty)) {
          return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
        } else if (snapshot.state == ListState.empty) {
          return const Center(child: Text("There's no character by your preference :("));
        } else if (snapshot.state == ListState.error) {
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
              }
            }),
          itemBuilder: (context, index) {
            if(index < rickMortyVM.characterList.length) {
              return CharacterCardWidget(character: rickMortyVM.characterList[index]);
            }else{
              return const Center(child: CircularProgressIndicator());
            }
          },
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemCount: (rickMortyVM.listFilterMode == ListFilterMode.none && rickMortyVM.isSearchPhraseEmpty) ? rickMortyVM.characterList.length + 1 : rickMortyVM.characterList.length,
        );
      }),
    );
  }
}
