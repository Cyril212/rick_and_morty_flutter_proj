import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';

class ListWidget<T extends ListVM> extends StatefulWidget {

  final Widget Function (BuildContext context)? initialLoadingWidget;
  final Widget Function (BuildContext context)? emptyListWidget;
  final Widget Function (BuildContext context)? errorWidget;
  final Widget Function (BuildContext context)? separatorBuilder;
  final Widget Function (BuildContext context, int index)? itemBuilder;


  const ListWidget({Key? key, this.initialLoadingWidget, this.emptyListWidget, this.errorWidget, this.separatorBuilder, this.itemBuilder}) : super(key: key);

  @override
  State<ListWidget> createState() => _ListWidgetState<T>();
}

class _ListWidgetState<T extends ListVM> extends State<ListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read<RickMortyListVM>().getCharacters(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: const Key("RickMortyListWidgetKey"),
      child: BlocConsumer<T, ListEvent>(listener: (context, characterListEvent) {
        final listVM = context.read<T>();

        switch (characterListEvent.state) {
          case ListState.idle:
          case ListState.loading:
            break;
          case ListState.success:
            listVM.isFetching = false;
            break;
          case ListState.empty:
            break;
          case ListState.error:
            listVM.isFetching = false;
            break;
        }
      }, builder: (BuildContext context, snapshot) {
        final listVM = context.read<T>();

        print("Length: ${listVM.currentList.length}");

        bool isInitialLoading = snapshot.state == ListState.idle || snapshot.state == ListState.loading && (listVM.currentList.isEmpty);
        if (isInitialLoading) {
          return widget.itemBuilder != null ? widget.initialLoadingWidget!(context) : const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
        } else if (snapshot.state == ListState.empty) {
          return widget.emptyListWidget != null ? widget.emptyListWidget!(context) : const Center(child: Text("There's no character by your preference :("));
        } else if (snapshot.state == ListState.error) {
          return widget.errorWidget != null ? widget.errorWidget!(context) : const Center(child: Text("Oops there's an error"));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 60),
          controller: _scrollController
            ..addListener(() {
              bool isEndOfList = _scrollController.offset == _scrollController.position.maxScrollExtent;
              bool shouldFetch = isEndOfList && listVM.allowFetch;

              if (shouldFetch && listVM.isFetching == false) {
                listVM.onEndOfList();
            }
            }),
          itemBuilder: (context, index) {
            if(index < listVM.currentList.length) {
              return widget.itemBuilder != null ? widget.itemBuilder!(context, index) : CharacterCardWidget(character: listVM.currentList[index]);
            }else{
              return widget.initialLoadingWidget != null ? widget.initialLoadingWidget!(context) : const Center(child: CircularProgressIndicator());
            }
          },
          separatorBuilder: (context, index) => widget.separatorBuilder != null ? widget.separatorBuilder!(context) : const SizedBox(height: 2),
          itemCount: listVM.allowFetch ? listVM.currentList.length + 1 : listVM.currentList.length,
        );
      }),
    );
  }
}
