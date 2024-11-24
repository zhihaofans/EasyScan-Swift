//
//  MainView.swift
//  Easy Scan
//
//  Created by zzh on 2024/11/23.
//

import SwiftUI
import SwiftUtils

struct MainView: View {
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        #if os(iOS)
        iosMainView()
        #else
        iosMainView()
        #endif
    }
}

@available(macOS, unavailable)
struct iosMainView: View {
    private let cameraUtil=CameraUtil()
    @State private var selectedTab=0
    @State private var showingAlert=false
    @State private var alertTitle: String="未知错误"
    @State private var alertText: String="未知错误"
    var body: some View {
        switch selectedTab {
        case 1:
//            Text("test")
            ScanView()
        case 2:
            NavigationView {
                List {
//                    NavigationLink("工具", destination: ToolView())
                }
                .navigationTitle("更多")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)) {
                            // TODO: 这里跳转到个人页面或登录界面
                            Image(systemName: "person")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        default:
            NavigationView {
                List {
                    NavigationLink("扫描二维码", destination: ScanView())
                    Button(action: {
                        cameraUtil.checkCameraPermissions {
                            print("checkCameraPermissions success")
                            alertTitle="申请相机权限"
                            alertText="成功🏅"
                            showingAlert=true
                        } fail: { err in
                            print("checkCameraPermissions fail:\(err)")
                            alertTitle="申请相机权限失败"
                            alertText=err
                            showingAlert=true
                        }

                    }) {
                        Text("申请相机权限")
                    }
                    .alert(alertTitle, isPresented: $showingAlert) {
                        Button("OK", action: {
                            alertTitle=""
                            alertText=""
                            showingAlert=false
                        })
                    } message: {
                        Text(alertText)
                    }
                }
                .navigationTitle(AppUtil().getAppName() /* "哔了个哩" */ )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)) {
                            // TODO: 这里跳转到个人页面或登录界面
                            Image(systemName: "person")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        }
        TabView(selection: $selectedTab) {
            Text("")
                .tabItem {
                    Label("主页", systemImage: "house")
                }
                .tag(0)

            Text("")
                .fixedSize(horizontal: false, vertical: true) // 纵向固定大小
                .tabItem {
                    Label("扫一扫", systemImage: "qrcode.viewfinder")
                }
                .tag(1)

            Text("")
                .fixedSize(horizontal: false, vertical: true) // 纵向固定大小
                .tabItem {
                    Label("更多", systemImage: "ellipsis")
                }
                .tag(2)
        }
        .frame(maxHeight: 50) // 限制最大高度
    }
}

#Preview {
    MainView()
}
