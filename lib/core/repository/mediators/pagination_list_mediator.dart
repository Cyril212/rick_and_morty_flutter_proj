abstract class PaginationListMediator {
  bool hasNextPage();

  void setNextPageNumToListByListMode(int? nextPageNum);

  void setPageNumToRequestByListMode([int? pageNum]);

  void setDefaultPageNum();

  void setSearchPhrase(String searchPhrase) {}
}