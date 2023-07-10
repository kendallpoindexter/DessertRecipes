//
//  DessertRecipesApp.swift
//  DessertRecipes
//
//  Created by Kendall Poindexter on 7/8/23.
//

import SwiftUI

@main
struct DessertRecipesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeListView()
            }
        }
    }
}
