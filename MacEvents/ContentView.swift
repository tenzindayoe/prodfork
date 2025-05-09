//
//  ContentView.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/14/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    var body: some View {
        ZStack{
            Color(red: 1/255, green: 66/255, blue: 106/255).ignoresSafeArea()
            EventHome()
                
        }
//       Color(red: 1/255, green: 66/255, blue: 106/255).ignoresSafeArea()
//    
//        VStack{
//            MapView()
//                .frame(height: 400)
//            
//            }
//    
//        Spacer()
//            
//            Image("MacLogo")
//                .aspectRatio(contentMode: .fit)
//                .offset(x:0,y:-)
//        
//            Image("MacMap")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .ignoresSafeArea()
////                .padding()
//                .offset(y:-140)
            


    }

}

#Preview {
    ContentView()
}
