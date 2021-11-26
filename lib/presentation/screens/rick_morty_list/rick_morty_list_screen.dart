import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/constants/text_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/abstract/rick_morty_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_detail/rick_morty_detail_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/widgets/rick_morty_list_widget.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/widgets/search_bar.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/character_card_widget.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/primary_app_bar.dart';

class RickMortyListScreen extends AbstractScreen {
  static const String route = '/rick_morty_list';

  const RickMortyListScreen({Key? key}) : super(key: key);

  @override
  _RickMortyListScreenState createState() => _RickMortyListScreenState();
}

class _RickMortyListScreenState extends RickMortyScreenState<RickMortyListScreen> {
  @override
  AbstractScreenStateOptions get options =>
      AbstractScreenStateOptions.basic(screenName: RickMortyListScreen.route, title: TextConstants.kAppTitle, safeArea: true);

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) => PrimaryAppbar(title: options.title);

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ListWidget<RickMortyListVM>(
              itemBuilder: (context, index) {
                final rickMortyListVM = context.read<RickMortyListVM>();

                final Character character = rickMortyListVM.currentList[index];
                return CharacterCardWidget(
                    character: character,
                    onClick: () {
                      pushNamed(context, RickMortyDetailScreen.route, arguments: RickMortyDetailArgs(character.id).toJson());
                    },
                    onFavoriteClick: (bool isChosen) {
                      rickMortyListVM.setFavouriteCharacterState(character.id, isChosen);
                    });
              },
            ),
          ],
        ),
        const SearchBar()
      ],
    );
  }
}
