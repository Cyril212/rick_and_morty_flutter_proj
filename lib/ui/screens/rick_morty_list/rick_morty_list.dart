import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/primary_app_bar.dart';

class RickMortyListScreen extends AbstractScreen {
  static const String route = '/';

  const RickMortyListScreen({Key? key}) : super(key: key);

  @override
  _RickMortyListScreenState createState() => _RickMortyListScreenState();
}

class _RickMortyListScreenState extends AbstractScreenState<RickMortyListScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Character> characterList = [];

  @override
  firstBuildOnly(BuildContext context) {
    context.read<RickMortyListVM>().fetchCharacterList();
    return super.firstBuildOnly(context);
  }

  @override
  AbstractScreenStateOptions get options =>
      AbstractScreenStateOptions.basic(screenName: RickMortyListScreen.route, title: "Rick and Morty", safeArea: true);

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: BlocConsumer<RickMortyListVM, CharacterListEvent>(listener: (context, characterListEvent) {
        final rickMortyVM = context.read<RickMortyListVM>();

        switch (characterListEvent.state) {
          case CharacterListState.idle:
            break;
          case CharacterListState.loading:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("loading")));
            break;
          case CharacterListState.success:
            context.read<RickMortyListVM>().isFetching = false;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            break;
          case CharacterListState.empty:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("empty")));
            break;
          case CharacterListState.error:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("error")));
            rickMortyVM.isFetching = false;
            break;
        }
      }, builder: (BuildContext context, snapshot) {
        final rickMortyVM = context.read<RickMortyListVM>();

        if (snapshot.state == CharacterListState.idle || snapshot.state == CharacterListState.loading && rickMortyVM.characterList.isEmpty) {
          return const CircularProgressIndicator();
        } else if (snapshot.state == CharacterListState.error) {
          return const Center(child: Text("Error"));
        }

        return ListView.separated(
          controller: _scrollController
            ..addListener(() {
              if (_scrollController.offset == _scrollController.position.maxScrollExtent && !context.read<RickMortyListVM>().isFetching) {
                context.read<RickMortyListVM>()
                  ..isFetching = true
                  ..fetchCharacterList();
              }
            }),
          itemBuilder: (context, index) => CharacterCardWidget(character: rickMortyVM.characterList[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemCount: rickMortyVM.characterList.length,
        );
      }),
    );
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) => PrimaryAppbar(title: options.title);
}
