//
//  ContentView.swift
//  mymx
//
//  Created by ice on 2024/6/17.
//

import SwiftUI
import NukeUI

enum Tab {
    case home
    case coffeeList
    case add
    case community
    case mine
}

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    @StateObject private var photoVM = PhotographVM()
    @StateObject private var weatherVM = WeatherVM()
    @StateObject private var factsVM = FactsVM()
    @StateObject private var coffeeListVM = CoffeeListVM()
    @StateObject private var addCoffeeVM = AddCoffeeVM()
    @StateObject private var shopVM = ShopVM()
    
    @State private var isLoggedIn: Bool = false
    @State private var selection: Tab = .home
    @State private var showAddCoffee = false
    @State private var joinRanking = 0
    
    var body: some View {
        ZStack{
            Text("")
                .onChange(of: [networkMonitor.isConnected], {
                    print("network is connected: \(networkMonitor.isConnected)")
                    if(networkMonitor.isConnected){
                        factsVM.nextFact()
                        modelData.getCoffeeList()

                        if(photoVM.photoList.isEmpty){
                            photoVM.fetchFirst()
                        }
                        if weatherVM.poetryWeathers.isEmpty{
                            weatherVM.fetchWeather(city: modelData.city)
                        }
                    }
                })
            
            TabView(selection: $selection, content: {
                CardHome(weatherVM: weatherVM, factsVM: factsVM, photoVM: photoVM)
                    .tag(Tab.home)
                CoffeeListView(viewModel: coffeeListVM)
                    .tag(Tab.coffeeList)
                EmptyView()
                    .tag(Tab.add)
                CommunityView(shopVM: shopVM)
                    .tag(Tab.community)
                MineView()
                    .tag(Tab.mine)
            })
            
            VStack{
                if addCoffeeVM.loading || addCoffeeVM.progress == 1 || !addCoffeeVM.errorMsg.isEmpty{
                    VStack{
                        HStack{
                            if(addCoffeeVM.imageList.count > 0){
                                Image(uiImage: addCoffeeVM.imageList[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipped()
                            }
                            if addCoffeeVM.progress == 1{
                                Text("添加成功！🎉 ")
                                Spacer()
                                Button("好的", action: {
                                    withAnimation{
                                        addCoffeeVM.cancel()
                                    }
                                    if(selection == .coffeeList){
                                        coffeeListVM.getCoffeeList()
                                    }else{
                                        GlobalParams.updateCoffee = true
                                    }
                                })
                            }else if !addCoffeeVM.errorMsg.isEmpty{
                                Text(addCoffeeVM.errorMsg)
                                    .foregroundStyle(.red)
                                Spacer()
                                Button("取消", action: {
                                    withAnimation{
                                        addCoffeeVM.cancel()
                                    }
                                })
                                .padding(.trailing)
                                Button("重试", action: {
                                    showAddCoffee = true
                                })
                            } else {
                                Text(addCoffeeVM.imageList.count > 0 ? "图片上传中，请稍作等待..." : "咖啡添加中...")
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        ProgressView(value: addCoffeeVM.progress)
                            .progressViewStyle(.linear)
                            .tint(Color(hex: "B4E380"))
                    }
                    .padding(.top)
                    .background(.regularMaterial)
                    .transition(.offset(x:0, y: -128))
                }
                
                if modelData.user == nil && selection != .home{
                    LoginView()
                        .onDisappear{
                            if(modelData.user != nil){
                                // 登录成功的逻辑
                                print("Login success")
                                if let rank = modelData.user?.joinRanking{
                                    self.joinRanking = rank
                                }
                                modelData.getCoffeeList()
                                if(selection == .coffeeList){
                                    coffeeListVM.getCoffeeList()
                                }
                            }
                        }
                }
                Spacer()
                MyTabView(active: $selection, showAddCoffee: $showAddCoffee)
                    .background(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        print("tap tab view")
                    }
            }
            .ignoresSafeArea(.keyboard)
            if joinRanking > 0 {
                JoinRankingView(joinRanking: $joinRanking)
                    .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showAddCoffee, content: {
            AddCoffeeView(showAddCoffee:$showAddCoffee, viewModel: addCoffeeVM)
                .environmentObject(modelData)
        })
        .onAppear(perform: {
            print("ContentView onAppear")
            if(modelData.coffeeList.isEmpty){
                modelData.getCoffeeList()
            }
        })
    }
}

struct MyTabView: View {
    @EnvironmentObject var modelData: ModelData
    
    @Binding var active: Tab
    @Binding var showAddCoffee: Bool
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 5), spacing: 0) {
            Rectangle()
                .foregroundStyle(.clear)
                .contentShape(.rect)
                .overlay{
                    Text("首页")
                        .font(active == .home ? .title3 : .body)
                        .fontWeight(.black)
                        .foregroundStyle(active == .home ? .primary : .secondary)
                        .padding(.vertical, 4)
                }
                .onTapGesture {
                    withAnimation{
                        active = .home
                    }
                }
            Rectangle()
                .foregroundStyle(.clear)
                .contentShape(.rect)
                .overlay{
                    Text("咖啡列表")
                        .font(active == .coffeeList ? .title3 : .body)
                        .fontWeight(.black)
                        .foregroundStyle(active == .coffeeList ? .primary : .secondary)
                        .padding(.vertical, 4)
                }
                .onTapGesture {
                    withAnimation{
                        active = .coffeeList
                    }
                }
            Rectangle()
                .foregroundStyle(.clear)
                .contentShape(.rect)
                .overlay{
                    Button(action: {
                        print("add Coffee")
                        if(modelData.user == nil){
                            withAnimation{
                                active = .coffeeList
                            }
                        }else{
                            self.showAddCoffee = true
                        }
                    }){
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 20)
                            .padding(12)
                            .foregroundStyle(.white)
                            .bold()
                            .background(.button)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(UIColor(white: 0.8, alpha: 0.8)), radius: 8, x: 0, y: 4)
                        
                    }
                }
                .frame(minHeight: 42)
                .onTapGesture {
                    
                }
            Rectangle()
                .foregroundStyle(.clear)
                .contentShape(.rect)
                .overlay{
                    Text("社区")
                        .font(active == .community ? .title3 : .body)
                        .fontWeight(.black)
                        .foregroundStyle(active == .community ? .primary : .secondary)
                        .padding(.vertical, 4)
                }
                .onTapGesture {
                    withAnimation{
                        active = .community
                    }
                }
            Rectangle()
                .foregroundStyle(.clear)
                .overlay{
                    Text("我")
                        .font(active == .mine ? .title3 : .body)
                        .fontWeight(.black)
                        .foregroundStyle(active == .mine ? .primary : .secondary)
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    withAnimation{
                        active = .mine
                    }
                }
        }
    }
}

#Preview {
    let modelData = ModelData()
    return ContentView()
        .environmentObject(modelData)
        .environment(NetworkMonitor())
}