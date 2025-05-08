//
//  CircleImage.swift
//  MacEvents
//
//  Created by Iren Sanchez on 4/30/25.
//

import Foundation
import SwiftUI

struct CircleImage: View {
    var image: Image
    var body: some View {
        image
            .resizable()
            .frame(width: 200, height: 200)
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
