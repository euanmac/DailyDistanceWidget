//
//  TestAlignment.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 01/02/2021.
//

import SwiftUI

let strings = ["First", "Second", "Three", "Four", "Five"]
struct TestAlignment: View {
    var body: some View {
//        GeometryReader { g in
            ZStack(alignment: .topTrailing) {
                Text("Hello")
                    .frame(alignment: .top)
                Image(systemName: "checkmark.circle.fill")
                                    .alignmentGuide(HorizontalAlignment.trailing) {
                                        $0[HorizontalAlignment.center]
                                    }
                                    .alignmentGuide(VerticalAlignment.top) {
                                        $0[VerticalAlignment.center]
                                    }

                
//                ForEach(strings.indices, id: \.self) {i in
//                    Text(strings[i])
//                        .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
//                            CGFloat(i) * dimension.height *  -10
//                        })
//                }
            }
//            .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
//                -1000
//            })
//        }
    }
}

struct TestAlignment_Previews: PreviewProvider {
    static var previews: some View {
//        HStack {
            TestAlignment()
                .frame(height: 300)
                .border(Color.black)
//            Rectangle()
//                .fill(Color.black)
//                .frame(height: 300)
//        }
    }
}
