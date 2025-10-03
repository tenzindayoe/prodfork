//
//  CircleImage.swift
//  MacEvents
//
//  Created by Iren Sanchez on 4/30/25.
//

import Foundation
import SwiftUI

///
/// An image formatted in the shape of a circle with detailling
///
struct CircleImage: View {
    var image: Image
    var body: some View {
        image
            .resizable()
            .frame(width: 174, height: 174)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
    
}
#Preview {
    CircleImage(image: Image("Janet Wallace Fine Arts Center"))
}
