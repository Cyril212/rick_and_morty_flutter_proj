import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/auth/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/authorization/authorization_screen.dart';

import '../../utils.dart';
import '../screens/rick_morty_list/widgets/favourite_mode_widget.dart';

class PrimaryAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const PrimaryAppbar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight(context) - statusBarHeight(context) / 10),
      height: preferredSize.height + statusBarHeight(context),
      child: Stack(
        children: [
          if(context.read<AuthProvider>().isAuthorized)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.login_outlined,color: kColorAmber,),
              onPressed: () {
                context.read<AuthProvider>().logOut();
                pushNamedNewStack(context, AuthorizationScreen.route);
              },
            ),
          ),
          Center(child: Text(title, style: kAppBarTextStyle)),
          Align(
            alignment: Alignment.centerRight,
            child: FilterModeWidget(),
          ),
        ],
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [kColorBlue, kColorAqua],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(0.5, 0.0),
            stops: [0.0, 0.5],
            tileMode: TileMode.clamp),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 48);
}
