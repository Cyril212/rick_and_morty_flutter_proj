import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/logger.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/list_vm.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class ListWidget<T extends ListVM> extends StatefulWidget {

  final Widget Function (BuildContext context, int index) itemBuilder;
  final Widget Function (BuildContext context)? initialLoadingWidget;
  final Widget Function (BuildContext context)? emptyListWidget;
  final Widget Function (BuildContext context)? errorWidget;
  final Widget Function (BuildContext context)? separatorBuilder;

  const ListWidget({Key? key, required this.itemBuilder, this.initialLoadingWidget, this.emptyListWidget, this.errorWidget, this.separatorBuilder}) : super(key: key);

  @override
  State<ListWidget> createState() => _ListWidgetState<T>();
}

class _ListWidgetState<T extends ListVM> extends State<ListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read<RickMortyListVM>().getCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: const Key("RickMortyListWidgetKey"),
      child: BlocConsumer<T, ListEvent>(listener: (context, characterListEvent) {
        final listVM = context.read<T>();

        switch (characterListEvent.listState) {
          case ListState.idle:
          case ListState.loading:
            break;
          case ListState.success:
            listVM.isNextPageFetching = false;
            break;
          case ListState.empty:
            break;
          case ListState.error:
            listVM.isNextPageFetching = false;
            break;
        }
      }, builder: (BuildContext context, snapshot) {
        final listVM = context.read<T>();

        Logger.d("Length: ${listVM.characterList.length}");

        if (listVM.isInitialLoading) {
          return widget.initialLoadingWidget != null ? widget.initialLoadingWidget!(context) : const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
        } else if (snapshot.listState == ListState.empty) {
          return widget.emptyListWidget != null ? widget.emptyListWidget!(context) : const Center(child: Text("There's no character by your preference :("));
        } else if (snapshot.listState == ListState.error) {
          return widget.errorWidget != null ? widget.errorWidget!(context) : const Center(child: Text("Oops there's an error"));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 60),
          controller: _scrollController
            ..addListener(() {
              bool isEndOfList = _scrollController.offset == _scrollController.position.maxScrollExtent;
              bool shouldFetch = isEndOfList && listVM.allowFetch;

              if (shouldFetch && listVM.isNextPageFetching == false) {
                listVM.onEndOfList();
            }
            }),
          itemBuilder: (context, index) {
            if(index < listVM.characterList.length) {
              return widget.itemBuilder(context, index);
            }else{
              return widget.initialLoadingWidget != null ? widget.initialLoadingWidget!(context) : const Center(child: CircularProgressIndicator());
            }
          },
          separatorBuilder: (context, index) => widget.separatorBuilder != null ? widget.separatorBuilder!(context) : const SizedBox(height: 2),
          itemCount: listVM.allowFetch ? listVM.characterList.length + 1 : listVM.characterList.length,
        );
      }),
    );
  }
}
