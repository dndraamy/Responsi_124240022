// import 'package:get/get.dart';
// import '../models/product_model.dart';
// import '../services/api_service.dart';
// import '../services/local_storage_service.dart';

// class CharacterController extends GetxController {
//   final ApiService _apiService = ApiService();

//   // Characters state
//   final RxList<Character> characters = <Character>[].obs;
//   final RxBool isLoadingCharacters = false.obs;
//   final RxString characterError = ''.obs;
//   final RxString selectedStatus = 'All'.obs; // 'All', 'Alive', 'Dead', 'Unknown'
//   final RxString searchName = ''.obs;

//   // Pagination state
//   final RxInt currentPage = 1.obs;
//   final RxInt totalCharacters = 0.obs;
//   final RxBool hasNextPage = true.obs;
//   final RxBool isLoadingMore = false.obs;

//   // Favorites state
//   final RxList<Character> favorites = <Character>[].obs;

//   // Episodes state
//   final RxList<Episode> episodes = <Episode>[].obs;
//   final RxBool isLoadingEpisodes = false.obs;
//   final RxString episodeError = ''.obs;

//   // Current user info
//   final RxString loggedInName = ''.obs;
//   final RxString loggedInUsername = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadCurrentUser();
//     loadFavorites();
//     fetchCharacters();
//     fetchEpisodes();
//   }

//   Future<void> loadCurrentUser() async {
//     final user = await LocalStorageService.getCurrentUser();
//     if (user != null) {
//       loggedInName.value = user['name'] ?? '';
//       loggedInUsername.value = user['username'] ?? '';
//     }
//   }

//   // Fetch Characters (Halaman pertama / reset filter)
//   Future<void> fetchCharacters() async {
//     isLoadingCharacters.value = true;
//     characterError.value = '';
//     currentPage.value = 1;
//     hasNextPage.value = true;

//     try {
//       final statusParam = selectedStatus.value == 'All' ? null : selectedStatus.value.toLowerCase();
//       final response = await _apiService.getCharacters(
//         page: 1,
//         status: statusParam,
//         name: searchName.value.isEmpty ? null : searchName.value,
//       );
//       characters.assignAll(response.characters);
//       totalCharacters.value = response.totalCount;
//       hasNextPage.value = response.hasNext;
//     } catch (e) {
//       characterError.value = e.toString();
//     } finally {
//       isLoadingCharacters.value = false;
//     }
//   }

//   // Infinite Scroll / Load More Characters
//   Future<void> loadMoreCharacters() async {
//     if (isLoadingMore.value || !hasNextPage.value || isLoadingCharacters.value) {
//       return;
//     }

//     isLoadingMore.value = true;

//     try {
//       final nextPage = currentPage.value + 1;
//       final statusParam = selectedStatus.value == 'All' ? null : selectedStatus.value.toLowerCase();
//       final response = await _apiService.getCharacters(
//         page: nextPage,
//         status: statusParam,
//         name: searchName.value.isEmpty ? null : searchName.value,
//       );

//       characters.addAll(response.characters);
//       currentPage.value = nextPage;
//       hasNextPage.value = response.hasNext;
//     } catch (_) {
//       // Abaikan error jaringan saat silent load more, user dapat scroll ulang
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }

//   void filterByStatus(String status) {
//     if (selectedStatus.value != status) {
//       selectedStatus.value = status;
//       fetchCharacters();
//     }
//   }

//   void searchByName(String name) {
//     searchName.value = name;
//     fetchCharacters();
//   }

//   // Fetch Episodes
//   Future<void> fetchEpisodes() async {
//     isLoadingEpisodes.value = true;
//     episodeError.value = '';
//     try {
//       final data = await ApiService.getEpisodes();
//       episodes.assignAll(data);
//     } catch (e) {
//       episodeError.value = e.toString();
//     } finally {
//       isLoadingEpisodes.value = false;
//     }
//   }

//   // Favorites management
//   Future<void> loadFavorites() async {
//     final list = await LocalStorageService.getFavorites();
//     favorites.assignAll(list);
//   }

//   bool isFavorite(int id) {
//     return favorites.any((c) => c.id == id);
//   }

//   Future<bool> toggleFavorite(Character character) async {
//     if (isFavorite(character.id)) {
//       await LocalStorageService.removeFavorite(character.id);
//       favorites.removeWhere((c) => c.id == character.id);
//       return false;
//     } else {
//       await LocalStorageService.addFavorite(character);
//       favorites.add(character);
//       return true;
//     }
//   }

//   Future<void> removeFavoriteAt(int id) async {
//     await LocalStorageService.removeFavorite(id);
//     favorites.removeWhere((c) => c.id == id);
//   }
// }
