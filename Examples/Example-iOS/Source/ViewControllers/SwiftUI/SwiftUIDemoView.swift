//
//  SwiftUIDemoView.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 22/12/2022.
//  Copyright © 2022 Mokten Pty Ltd. All rights reserved.
//

import UIKit
import SwiftUI
import StubPlay

@available(iOS 14.0, *)
struct SwiftUIDemoView: View {
    
    @State var stubStarted: Bool = false
    
    private var url: String {
        "https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png?time=\(Date().timeIntervalSince1970)" 
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            if #available(iOS 15.0, *) {
                AsyncImage(url: URL(string: url))
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 300)
            } else {
                Text("min iOS 15")
            }
            
            Spacer()
            
            Button(stubStarted ? "Stop" : "Start") {
                toggleStubbing()
            }
            
            Spacer()
        }.onAppear {
            stubStarted = StubManager.shared.isStubbing
        }
    }
    
    func toggleStubbing() {
        if stubStarted {
            StubManager.shared.stop()
        } else {
            StubManager.shared.start()
        }
        stubStarted.toggle()
    }
}

extension UIViewController {
    static var swiftUIDemoView: UIViewController {
        if #available(iOS 14.0, *) {
            let vc = UIHostingController(rootView: SwiftUIDemoView())
            vc.title = "Stub Control"
            return vc
        } else {
            return UIViewController()
        }
    }
}

@available(iOS 14.0, *)
struct SwiftUIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIDemoView()
    }
}
