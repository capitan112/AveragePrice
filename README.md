# AveragePrice

# Assumption and implementations

## Swift 5, UIKit, iOS 17.0, Combine in the app.

## In requirement was "Calculate the average property price from the results" but I especially have added an option for an average price depending on the size of the home with chosen bedrooms in UIPickerView. I think it is more informative.

- Implementation architecture MVVM-C - split logic, model and UI
- Async/await in REST request
- Using Combine and reactive approach
- Smooth appears Data through UIView alpha animation after downloading
- Checking average for all possible options and for specific homes with specific bedrooms with UIPickerView
- Lazy instance init when it needs in ViewContoller
- Unit test for a fetch request
- Message depends on the Error type
- Handling error messages in the app
- No storyboards only code and programmatic constraints
- Dependency injection and using OOP,  Protocol Type for models and for HttpClients - gives flexibility for app
