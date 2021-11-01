import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_source.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/abstract_pagination.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';

/// Used to communicate between VM and Manager
abstract class AbstractRepository<T extends DataSource> extends AbstractPagination<Character>{

  AbstractRepository();

  Future<T> fetchResult();
}