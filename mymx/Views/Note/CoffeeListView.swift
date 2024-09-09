//
//  CoffeeListView.swift
//  mymx
//
//  Created by ice on 2024/7/14.
//

import SwiftUI
import NukeUI

struct CoffeeListView: View {
    @EnvironmentObject var modelData: ModelData
    @StateObject private var viewModel = CoffeeListVM()
    
    @State private var showDelete = false
    @State private var deleteCoffee = CoffeeModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(modelData.coffeeList) { coffee in
                    CoffeeRow(coffee: coffee)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteCoffee = coffee
                                showDelete = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Coffee List")
        .onAppear(perform: modelData.getCoffeeList)
        .alert("Delete Coffee", isPresented: $showDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteCoffee(coffeeId: deleteCoffee.id)
                if let index = modelData.coffeeList.firstIndex(of: deleteCoffee) {
                    modelData.coffeeList.remove(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to delete \(deleteCoffee.name)?")
        }
    }
}

struct CoffeeRow: View {
    let coffee: CoffeeModel
    
    var body: some View {
        HStack {
            LazyImage(url: URL(string: coffee.imageUrl)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(coffee.name)
                    .font(.headline)
                Text(coffee.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", coffee.price))")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    CoffeeListView()
        .environmentObject(ModelData())
}