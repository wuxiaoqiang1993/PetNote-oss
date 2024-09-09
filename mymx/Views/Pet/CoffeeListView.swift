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
    
    @StateObject private var viewModel = DeleteCoffeeVM()
    @State private var showDelete = false
    @State private var deleteCoffee = CoffeeModel()
    
    var body: some View {
            ScrollView{
                LazyVStack{
                    ForEach(modelData.coffeeList){ coffee in
                        HStack(spacing: 0){
                            LazyImage(url: URL(string: coffee.imageUrl)){ state in
                                state.image?
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(.rect(cornerRadius: 10))
                            }
                            .padding(.trailing)
                            VStack(alignment: .leading){
                                HStack{
                                    Text(coffee.name)
                                        .font(.title)
                                        .foregroundStyle(.primary)
                                    
                                    Text(CoffeeTypeModel.getModel(coffee.type).cn)
                                    
                                    Text(RoastLevelModel.getModel(RoastLevel(rawValue: coffee.roastLevel) ?? .medium).cn)
                                }
                                Text("¥\(String(format: "%.2f", coffee.price))")
                                Text(coffee.description)
                            }
                            .foregroundStyle(.secondary)
                            Spacer(minLength: 0)
                            VStack(spacing: 16){
                                
                                Button(action: {
                                    deleteCoffee = coffee
                                    showDelete = true
                                }, label: {
                                    Label("删除", systemImage: "trash")
                                })
                                .foregroundStyle(.red)
                                .alert("是否删除 \(deleteCoffee.name) ?", isPresented: $showDelete, actions: {
                                    Button("取消", role: .cancel, action: {
                                        self.deleteCoffee = CoffeeModel()
                                    })
                                    Button("删除", role: .destructive, action: {
                                        showDelete = false
                                        print("delete \(self.deleteCoffee)")
                                        self.viewModel.deleteCoffee(coffeeId: self.deleteCoffee.id)
                                        if let index = modelData.coffeeList.firstIndex(of: deleteCoffee){
                                            withAnimation{
                                                modelData.coffeeList.remove(at: index)
                                            }
                                        }
                                        self.deleteCoffee = CoffeeModel()
                                    })
                                }, message: {
                                    Text("本操作将删除 \(deleteCoffee.name)。")
                                })
                                
                                NavigationLink(destination: EditCoffeeView(coffeeInfo: coffee), label:{
                                    Label("编辑", systemImage: "pencil")
                                        .foregroundStyle(.blue)
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .onAppear(perform: modelData.getCoffeeList)
    }
}

#Preview {
    CoffeeListView()
        .environmentObject(ModelData())
}