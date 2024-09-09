//
//  MineView.swift
//  mymx
//
//  Created by ice on 2024/7/8.
//

import SwiftUI
import NukeUI

struct MineView: View {
    @EnvironmentObject var modelData: ModelData
    
    @State private var showProfile = false
    let screenWidth = UIScreen.main.bounds.size.width

    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 0){
                    LazyImage(url: URL(string: "https://example.com/coffee-background.jpg")){ state in
                        state.image?
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                    }
                    .frame(height: 400)
                    .padding(.top, -80)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Coffee Enthusiast Profile")
                            .font(.title)
                            .fontWeight(.bold)

                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack(alignment: .leading) {
                                Text(modelData.user?.name ?? "Coffee Lover")
                                    .font(.headline)
                                Text(modelData.user?.mail ?? "coffee@example.com")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Coffee Stats")
                                .font(.headline)
                            HStack {
                                Stat(title: "Coffees Tried", value: "\(modelData.coffeeList.count)")
                                Stat(title: "Favorite Roast", value: "Medium")
                                Stat(title: "Brewing Method", value: "Pour Over")
                            }
                        }

                        Divider()

                        NavigationLink(destination: CoffeeListView()) {
                            Text("My Coffee Collection")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brown)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.all)
            .toolbar{
                if(modelData.user != nil){
                    ToolbarItem(placement: .topBarTrailing){
                        Button{
                            showProfile.toggle()
                        } label: {
                            Label("User Profile", systemImage: "gearshape")
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showProfile, content: {
                ProfileView(showProfile:$showProfile)
            })
        }
    }
}

struct Stat: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let modelData = ModelData()
    return MineView()
        .environmentObject(modelData)
}