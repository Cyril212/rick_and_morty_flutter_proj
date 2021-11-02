# Rick And Morty Test Project

Rick And Morty TP is a Flutter application made in order to demonstrate basic View-ViewModel-Repository architecture by using [Provider](https://pub.dev/packages/provider) and [BLoC](https://pub.dev/packages/bloc) libs. 

API used in the project [Rick and Morty API](https://rickandmortyapi.com/). 

## Installation

Clone the project and you're ready to go :)

## Features
- Pagination
- List sorting
- Search
- Communication through REST with Hive DB caching.
- Unit tests

## Project structure
<img width="483" alt="Screenshot 2021-11-01 at 20 21 02" src="https://user-images.githubusercontent.com/10762970/139729226-ce282bbc-d70e-449e-a4a8-687e4acfd47e.png">

## Data layer architecture

<img width="1653" alt="Screenshot 2021-11-01 at 20 17 50" src="https://user-images.githubusercontent.com/10762970/139729327-ec594f35-fb72-43ba-87dc-eb4f98835987.png">

## Data Source

<img width="1567" alt="Screenshot 2021-11-01 at 20 18 58" src="https://user-images.githubusercontent.com/10762970/139730179-2e1e5acc-4cba-413e-bf37-075f2c02db68.png">

## Repository

<img width="366" alt="Screenshot 2021-11-01 at 20 18 08" src="https://user-images.githubusercontent.com/10762970/139729420-2b1ca57c-3ab3-4b4e-beb9-37bcf61cff8a.png">

## UI - Data Layer dependency

<img width="367" alt="Screenshot 2021-11-01 at 20 43 21" src="https://user-images.githubusercontent.com/10762970/139731732-b17aff5f-6f2e-44de-bd9d-ed25232e2f56.png">

## Tests

To test cubit initialization:
```python
flutter --no-color test --machine --start-paused test/bloc_tests.dart
```
To test repository functions:
```python
flutter --no-color test --machine --start-paused test/repository_tests.dart
```
## Additional Info
Visual elements that were reused and slightly modified from [link](https://github.com/sergiandreplace/flutter_planets_tutorial).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
