import Foundation

/// Enum representing possible view states.
enum ViewState {
    
    /// Idle state when view is initialized.
    case idle
    
    /// Loading state when data is being fetched.
    case loading
    
    /// Loaded state when data is ready.
    case loaded
    
    /// Error state if data fetching fails.
    case error
}
