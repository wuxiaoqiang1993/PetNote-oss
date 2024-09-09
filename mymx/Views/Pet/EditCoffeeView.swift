//
//  EditCoffeeView.swift
//  mymx
//
//  Created by ice on 2024/8/2.
//

import SwiftUI
import Mantis
import PhotosUI
import NukeUI

struct EditCoffeeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var modelData: ModelData

    @State var coffeeInfo: CoffeeModel
    @State private var selectedImage: UIImage? = nil
    @State private var croppedImage: UIImage? = nil
    @State private var photoList: [PhotosPickerItem] = []
    
    @State private var showingImageCropper = false
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .canUseMultiplePresetFixedRatio(defaultRatio: 1)
    @State private var cropperType: ImageCropperType = .normal
    @State private var cropShapeType: Mantis.CropShapeType = .circle(maskOnly: true)
    
    @StateObject private var addCoffeeVM = AddCoffeeVM(isUpdate: true)
    @State private var showAlert = false
    
    var body: some View {
        Form{
            Section(content: {
                HStack{
                    Text("名称")
                    Spacer()
                    TextField("请输入咖啡名称", text: $coffeeInfo.name)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .foregroundStyle(.secondary)
                }
                .frame(minHeight: 40)
                
                Picker("类型", selection: $coffeeInfo.type) {
                    ForEach(CoffeeType.allCases) { type in
                        Text(CoffeeTypeModel.getModel(type).cn).tag(type.rawValue)
                    }
                }.frame(minHeight: 40)
                
                Picker("烘焙程度", selection: $coffeeInfo.roastLevel) {
                    ForEach(RoastLevel.allCases) { level in
                        Text(RoastLevelModel.getModel(level).cn).tag(level.rawValue)
                    }
                }.frame(minHeight: 40)
                
                HStack{
                    Text("价格")
                    Spacer()
                    TextField("请输入价格", value: $coffeeInfo.price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
                .frame(minHeight: 40)
                
                HStack {
                    Text("图片")
                    Spacer()
                    
                    PhotosPicker(selection: $photoList,
                                 maxSelectionCount: 1,
                                 matching: .images){
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else if !coffeeInfo.imageUrl.isEmpty{
                            LazyImage(url: URL(string: coffeeInfo.imageUrl)){ state in
                                state.image?
                                    .resizable()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        } else {
                            Image(systemName: "cup.and.saucer")
                                .resizable()
                                .foregroundStyle(Color.iconfill)
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .onChange(of: photoList, {
                        fillImages()
                    })
                }.frame(minHeight: 64)
                
                TextField("描述...", text: $coffeeInfo.description)
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 80)
                    .submitLabel(.done)
                
            }, header: {Text("咖啡信息（必填）")}, footer: ({
                
            })
            )}
        .sheet(isPresented: $showingImageCropper) {
            ImageCropper(image: $selectedImage,
                         cropShapeType: $cropShapeType,
                         presetFixedRatioType: $presetFixedRatioType,
                         type: $cropperType)
            .onDisappear(perform: {
                print("cropped")
            })
            .ignoresSafeArea()
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("取消")
                })
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                if(addCoffeeVM.loading){
                    ProgressView("更新中...")
                } else {
                    Button(action: {                Button(action: {
                    addCoffeeVM.updateCoffee(coffee: coffeeInfo, image: selectedImage)
                }, label: {
                    Text("确定")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.button)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
            }
        })
    })
    .navigationBarBackButtonHidden()
    .onChange(of: addCoffeeVM.success, {
        modelData.getCoffeeList()
        presentationMode.wrappedValue.dismiss()
    })
    .onChange(of: addCoffeeVM.errorMsg, {
        if(addCoffeeVM.errorMsg.count > 0){
            self.showAlert = true
        }
    })
    .alert(addCoffeeVM.errorMsg, isPresented: $showAlert){
        Button("OK", role: .cancel, action: {
            addCoffeeVM.errorMsg = ""
        })
    }
    .navigationTitle("编辑咖啡")
}

func fillImages(){
    if photoList.isEmpty {
        return
    }
    Task{
        if let imageData = try? await photoList.first?.loadTransferable(type: Data.self) {
            if let image = UIImage(data: imageData) {
                withAnimation{
                    selectedImage = image
                    if selectedImage != nil {
                        showingImageCropper = true
                    }
                }
            }
        }
    }
}