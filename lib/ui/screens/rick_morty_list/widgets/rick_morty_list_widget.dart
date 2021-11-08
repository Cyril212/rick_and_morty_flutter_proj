import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';

class RickMortyListWidget<T extends ListVM> extends StatefulWidget {

  final Widget Function (BuildContext context)? initialLoadingWidget;
  final Widget Function (BuildContext context)? emptyListWidget;
  final Widget Function (BuildContext context)? errorWidget;
  final Widget Function (BuildContext context)? separatorBuilder;
  final Widget Function (BuildContext context, int index)? itemBuilder;


  const RickMortyListWidget({Key? key, this.initialLoadingWidget, this.emptyListWidget, this.errorWidget, this.separatorBuilder, this.itemBuilder}) : super(key: key);

  @override
  State<RickMortyListWidget> createState() => _RickMortyListWidgetState<T>();
}

class _RickMortyListWidgetState<T extends ListVM> extends State<RickMortyListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool isFetching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read<RickMortyListVM>().fetchList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: const Key("RickMortyListWidgetKey"),
      child: BlocConsumer<T, ListEvent>(listener: (context, characterListEvent) {
        switch (characterListEvent.state) {
          case ListState.idle:
          case ListState.loading:
            break;
          case ListState.success:
           isFetching = true;
            break;
          case ListState.empty:
            break;
          case ListState.error:
            isFetching = false;
            break;
        }
      }, builder: (BuildContext context, snapshot) {
        final listVM = context.read<T>();

        bool isInitialLoading = snapshot.state == ListState.idle || snapshot.state == ListState.loading && (listVM.currentList.isEmpty);
        if (isInitialLoading) {
          return widget.itemBuilder != null ? widget.initialLoadingWidget!(context) : const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
        } else if (snapshot.state == ListState.empty) {
          return widget.emptyListWidget != null ? widget.emptyListWidget!(context) : const Center(child: Text("There's no character by your preference :("));
        } else if (snapshot.state == ListState.error) {
          return widget.errorWidget != null ? widget.errorWidget!(context) : const Center(child: Text("Oops there's an error"));
        }

        return ListView.separated(
          controller: _scrollController
            ..addListener(() {
              bool shouldFetch = _scrollController.offset == _scrollController.position.maxScrollExtent && listVM.shouldFetch;
              if (shouldFetch) {
                isFetching = true;
                listVM.fetchList();
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
          itemCount: listVM.shouldFetch ? listVM.currentList.length + 1 : listVM.currentList.length,
        );
      }),
    );
  }
}
