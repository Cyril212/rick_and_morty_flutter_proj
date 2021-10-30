import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';
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
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<RickMortyListVM, CharacterListEvent>(builder: (BuildContext context, snapshot) {
            switch (snapshot.state) {
              case CharacterListState.idle:
                return Text("idle");
              case CharacterListState.loading:
                return Text("loading");
              case CharacterListState.success:
                final characters = snapshot.characterList!.map((character) {
                  return CharacterCardWidget(
                    character: character,
                  );
                }).toList();
                // characters.map((e) => null)
                return SingleChildScrollView(
                    child: Column(
                  children: characters,
                ));
              case CharacterListState.error:
                return Container(child: Text("error"));
            }
          }),
        ),
        //todo: uncomment for test purpose
        OutlinedButton(onPressed: () {
          context.read<RickMortyListVM>().fetchCharacterList();
        }, child: Text("Refresh"))
      ],
    );
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) => PrimaryAppbar(title: options.title);

}
