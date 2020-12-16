//
//  GraphPlotArea.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 11/12/2020.
//

import SwiftUI

struct GraphPlotAreaView: View {
    var body: some View {
        GraphPlotArea(maxScaleX: 10, minScaleX: 0, xInterval: 1, maxScaleY: 10, minScaleY: 0, yInterval: 1)
    }
}

struct GraphPlotArea: Shape {
    
    let maxScaleX: Int
    let minScaleX: Int
    let xInterval: Int
    let maxScaleY: Int
    let minScaleY: Int
    let yInterval: Int
    
    init(maxScaleX: Int,
         minScaleX: Int = 0,
         xInterval: Int = 1,
         maxScaleY: Int,
         minScaleY: Int = 0,
         yInterval: Int = 1) {
        
        self.maxScaleX = maxScaleX
        self.maxScaleY = maxScaleY
        self.minScaleX = minScaleX
        self.minScaleY = minScaleY
        self.xInterval = xInterval
        self.yInterval = yInterval
        
    }
    
    
    func path(in rect: CGRect) -> Path {
        
        let intHeight = rect.height / CGFloat(maxScaleY - minScaleY)
        let intWidth = rect.width / CGFloat(maxScaleX - minScaleX)
        
        var path = Path()
        
        for y in stride(from: 0, through:((maxScaleY - minScaleY)), by: yInterval) {
        
            path.move(to: CGPoint(x: 0, y: intHeight * CGFloat(y)))
            path.addLine(to: CGPoint(x: rect.width, y: intHeight * CGFloat(y)))
        }
        
        for x in stride(from: 0, through:((maxScaleX - minScaleX)), by: xInterval){
        
            path.move(to: CGPoint(x: intWidth * CGFloat(x), y: 0))
            path.addLine(to: CGPoint(x: intWidth * CGFloat(x), y: rect.height))
        }
        
        return path
    }
}

struct GraphPlotArea_Previews: PreviewProvider {
    static var previews: some View {
        GraphPlotArea(maxScaleX: 24, maxScaleY: 3)
            .stroke(Color.black)
            .frame(width: 200, height: 200)
            
        GraphPlotArea(maxScaleX: 24, minScaleX: 12, xInterval: 2, maxScaleY: 3000,minScaleY: 0, yInterval: 1000)
            .stroke(Color.black)
            .frame(width: 200, height: 200)
        
        
    }
}
