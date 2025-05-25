import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the different states/screens the AppContainer can display
// Using a sealed class (or union type) is a modern way to represent this.
// Requires Dart 2.17 or later.
sealed class NavigationState {
  const NavigationState(); // Add const constructor

  // Represents one of the main sections (Dashboard, Warehouses, Products, etc.)
  const factory NavigationState.mainSection(int index) =
      MainSectionNavigationState;

  // Represents the "Create Transport Task" form
  const factory NavigationState.createTask() = CreateTaskNavigationState;

  // Represents the details screen for a specific Warehouse
  const factory NavigationState.warehouseDetails(String warehouseId) =
      WarehouseDetailsNavigationState;

  // Represents the details screen for a specific Product
  // Optional: include warehouseId/stockItemId if navigating from a specific stock location
  const factory NavigationState.productDetails(String productId,
      {String? warehouseId,
      String? stockItemId}) = ProductDetailsNavigationState;

  // TODO: Add states for other create/detail screens (e.g., create product, customer details, etc.)
}

// Concrete implementations of the sealed class
// These are simple classes that hold the necessary parameters for each state.
class MainSectionNavigationState extends NavigationState {
  final int index;
  const MainSectionNavigationState(this.index);

  // Override equals and hashCode for comparing states
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MainSectionNavigationState &&
          runtimeType == other.runtimeType &&
          index == other.index);
  @override
  int get hashCode => index.hashCode;
}

class CreateTaskNavigationState extends NavigationState {
  const CreateTaskNavigationState();
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreateTaskNavigationState && runtimeType == other.runtimeType);
  @override
  int get hashCode => 0; // Or use a unique hash
}

class WarehouseDetailsNavigationState extends NavigationState {
  final String warehouseId;
  const WarehouseDetailsNavigationState(this.warehouseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarehouseDetailsNavigationState &&
          runtimeType == other.runtimeType &&
          warehouseId == other.warehouseId);
  @override
  int get hashCode => warehouseId.hashCode;
}

class ProductDetailsNavigationState extends NavigationState {
  final String productId;
  final String? warehouseId;
  final String? stockItemId;
  const ProductDetailsNavigationState(this.productId,
      {this.warehouseId, this.stockItemId});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductDetailsNavigationState &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          warehouseId == other.warehouseId &&
          stockItemId == other.stockItemId);
  @override
  int get hashCode =>
      productId.hashCode ^ warehouseId.hashCode ^ stockItemId.hashCode;
}

// Provider that manages the current navigation state
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  // Initial state could be Dashboard Overview
  return NavigationNotifier(const NavigationState.mainSection(0));
});

// Notifier to update the navigation state
class NavigationNotifier extends StateNotifier<NavigationState> {
  // A list to keep track of the navigation history (for back functionality)
  final List<NavigationState> _history = [];

  NavigationNotifier(NavigationState initialState) : super(initialState) {
    _history.add(initialState); // Add initial state to history
  }

  // Method to go to a specific state
  void go(NavigationState newState) {
    // Avoid pushing the same state multiple times consecutively unless it's a main section
    if (_history.isNotEmpty &&
        _history.last == newState &&
        !(newState is MainSectionNavigationState)) {
      return; // Don't push same state again (except for main sections)
    }

    state = newState;
    _history.add(newState); // Add the new state to history
    print('Navigation: -> $newState (History: ${_history.length})');
  }

  // Method to go back to the previous state
  void back() {
    if (_history.length > 1) {
      _history.removeLast(); // Remove current state from history
      state = _history.last; // Set state to the previous state
      print('Navigation: <- $state (History: ${_history.length})');
    } else {
      // Optionally handle what happens when trying to go back from the initial state
      print('Navigation: Cannot go back from initial state.');
    }
  }

  // Optional: Method to go back to a specific main section index (e.g., clicking sidebar)
  void goToMainSection(int index) {
    // Clear history and go to the main section
    _history.clear();
    final newState = NavigationState.mainSection(index);
    state = newState;
    _history.add(newState);
    print(
        'Navigation: Go to Main Section $index (History: ${_history.length})');
  }
}
