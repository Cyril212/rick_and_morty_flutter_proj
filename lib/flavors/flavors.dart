enum Flavor {
  DEV,
  STAGE,
  PROD,
}

extension FlavorName on Flavor {
  String get name => toString().split('.').last;
}

class FlavorManager {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'RicknMorty Dev';
      case Flavor.STAGE:
        return 'RicknMorty Stage';
      case Flavor.PROD:
        return 'RicknMorty';
      default:
        return 'title';
    }
  }

}
