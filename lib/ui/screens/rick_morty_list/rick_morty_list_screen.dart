import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/widgets/rick_morty_list_widget.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/widgets/search_bar.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/primary_app_bar.dart';

class RickMortyListScreen extends AbstractScreen {
  static const String route = '/';

  const RickMortyListScreen({Key? key}) : super(key: key);

  @override
  _RickMortyListScreenState createState() => _RickMortyListScreenState();
}

class _RickMortyListScreenState extends AbstractScreenState<RickMortyListScreen> {

  @override
  AbstractScreenStateOptions get options =>
      AbstractScreenStateOptions.basic(screenName: RickMortyListScreen.route, title: "Rick and Morty", safeArea: true);

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) => PrimaryAppbar(title: options.title);

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: const [
            ListWidget<RickMortyListVM>(),
          ],
        ),
        const SearchBar()
      ],
    );
  }

}
