#Property Price Calculator App

## Assumptions and Implementations

### Technologies Used
- Swift 5
- UIKit
- iOS 17.0
- Combine

## Key Features and Enhancements
### Average Property Price Calculation:

- Calculates the average property price from the results.
- Includes an option to calculate the average price based on the size of homes with chosen bedrooms using a UIPickerView for more detailed insights.

### Architecture:
- Implements MVVM-C (Model-View-ViewModel-Coordinator) to effectively separate logic, model, and UI components.

### Async/Await:
- Utilizes async/await for handling REST requests, enhancing code readability and performance.

### Reactive Approach with Combine:
- Employs Combine for managing asynchronous data streams in a reactive programming style.

### UI Enhancements:
- Smooth data appearance through UIView alpha animation after downloading.

### Average Price Calculation Options:
- Provides options for calculating the average price for all properties and specific homes with selected bedrooms using UIPickerView.

### Lazy Initialization:
- Implements lazy instance initialization in ViewController to optimize resource usage.

### Unit Testing:
- Includes unit tests for fetch requests to ensure reliability and accuracy.

### Error Handling:
- Displays messages based on the type of error encountered.
- Handles error messages within the app for better user experience.

### Formatting:
- Formats the average price answer for better readability and presentation.

### Code-Only Implementation:
- Avoids using storyboards, utilizing programmatic constraints for UI layout instead.

### Dependency Injection and OOP:
- Applies dependency injection and uses Protocol Types for models and HTTP clients to enhance flexibility and maintainability.
