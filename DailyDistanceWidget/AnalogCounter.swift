import SwiftUI
import Foundation



struct AnalogCounter_Previews: PreviewProvider {
    static  var previews: some View {
        CounterPreview()
    }
}

struct CounterPreview: View {
    @State private var flag = false
    @State private var number: Double = 21

    var body: some View {
        VStack {
            Color.clear
            
            Slider(value: $number, in: 0...999)
            Text("Number = \(number)")

            HStack(spacing: 10) {
                MyButton(label: "0", font: .headline) {
                    withAnimation(Animation.easeInOut) {
                    //withAnimation(Animation.interpolatingSpring(mass: 0.1, stiffness: 1, damping: 0.4, initialVelocity: 0.2)) {
                        self.number = 0
                    }
                }

                MyButton(label: "29.8", font: .headline) {
                    withAnimation(Animation.spring()) {
//                    withAnimation(Animation.interpolatingSpring(mass: 0.1, stiffness: 1, damping: 0.4, initialVelocity: 0.2)) {
                        self.number = 29.8
                    }
                }

                MyButton(label: "298", font: .headline) {
                    withAnimation(Animation.spring()) {
//                    withAnimation(Animation.interpolatingSpring(mass: 0.1, stiffness: 1, damping: 0.4, initialVelocity: 0.2)) {
                        self.number = 298
                    }
                }
                
                MyButton(label: "300", font: .headline) {
                    withAnimation(Animation.spring()) {
//                    withAnimation(Animation.interpolatingSpring(mass: 0.1, stiffness: 1, damping: 0.4, initialVelocity: 0.2)) {
                        self.number = 300
                    }
                }
                
                MyButton(label: "301", font: .headline) {
                    withAnimation(Animation.spring()) {
                    //withAnimation(Animation.interpolatingSpring(mass: 0.1, stiffness: 1, damping: 0.4, initialVelocity: 0.2)) {
                        self.number = 301
                    }
                }
            }

        }
        .overlay(AnalogCounter(number: number))
        
    }
}

struct AnalogCounter: View {
    let number: Double
    let decimals: Int = 1
    let integers: Int = 3
    
    var body: some View {
        Text("00")
            .modifier(MovingCounterModifier(number: number, decimals: decimals, integers: integers))
    }
    
    struct MovingCounterModifier: AnimatableModifier {
        @State private var height: CGFloat = 0

        var number: Double
        let decimals: Int
        let integers: Int
        
        var animatableData: Double {
            get { number }
            set { number = newValue }
        }
        
        func body(content: Content) -> some View {

            let font = Font.custom("Courier New", size: 34).bold()
            
            let split = modf(number)
            
            
            let u = Int(number) % 10
            let t = Int(number / 10) % 10
            let h = Int(number / 100) % 10
            
            var decimalReels = Array(repeating: CounterReel(digit: u, isFraction: false), count: decimals)
            var integerReels = Array(repeating: CounterReel(digit: u, isFraction: true), count: integers)
                   
            var counterReels = Array(repeating: CounterReel(digit: u, isFraction: false), count: integers)
            counterReels += Array(repeating: CounterReel(digit: u, isFraction: true), count: decimals)
            
            
//            for (index, item) in decimalReels.enumerated() {
//                decimalReels[index] =
//            }
//
            //let d = (0..<decimals).reversed().map { pow(Double10,$0) }
            
            let uReel = CounterReel(digit: u, isFraction: true)
            let tReel = CounterReel(digit: t, isFraction: true)
            let hReel = CounterReel(digit: h, isFraction: false)
            
            let uOffset = CGFloat(-1) * (CGFloat(number) - CGFloat(Int(number)))
            let tOffset = u == 9 ? uOffset : 0
            let hOffset = t == 9 ? tOffset : 0
            
            return HStack(alignment: .top, spacing: 1) {
                CounterReelView(counterReel: hReel, font: font, hOffset: hOffset)
                CounterReelView(counterReel: tReel, font: font, hOffset: tOffset)
                CounterReelView(counterReel: uReel, font: font, hOffset: uOffset)
            }
            .background(Color.black)
            .clipShape(ClipShape(a: "Clip"))
            .overlay(ShadowBorder()
                     
            )
                
        }
        

    }
    
    struct BackShape: Shape {
        func path(in rect: CGRect) -> Path {
            let r = rect
            let h = (r.height / 5.0 + 30.0)
            var p = Path()
            
            let cr = CGRect(x: (rect.width - 80)/2, y: (r.height - h) / 2.0, width: 80, height: h)
            p.addRoundedRect(in: cr, cornerSize: CGSize(width: 5.0, height: 5.0))
            
            return p
        }
    }
    
    struct ShadowBorder: View {
        var body: some View {
            GeometryReader() {geo in
                Color.clear
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .mask(RoundedRectangle(cornerRadius: 5).fill(LinearGradient(Color.black, Color.clear)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .mask(RoundedRectangle(cornerRadius: 5).fill(LinearGradient(Color.clear, Color.black)))
                    )
                    .offset(x: 0, y: (geo.size.height / 5.0 * 2) - 15)
                    .frame(height: (geo.size.height / 5.0 ) + 30)
            }
        }
    }
    
    struct ClipShape: Shape {
        let a: String
        
        func path(in rect: CGRect) -> Path {
            let r = rect
            let h = (r.height / 5.0 + 30.0)
            var p = Path()
            
            let cr = CGRect(x: 0, y: (r.height - h) / 2.0, width: r.width, height: h)
            p.addRoundedRect(in: cr, cornerSize: CGSize(width: 5.0, height: 5.0))
            
            return p
        }
    }

}

struct ShiftEffect: GeometryEffect {
    var pct: CGFloat = 1.0
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return .init(.init(translationX: 0, y: (size.height / 5.0) * pct))
    }
}

struct MyButton: View {
    let label: String
    var font: Font = .title
    var textColor: Color = .white
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            Text(label)
                .font(.custom("Courier New", size: 16)).bold()
                .padding(10)
                .frame(width: 60)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.green).shadow(radius: 2))
                .foregroundColor(textColor)
            
        })
    }
}

struct CounterReel {
    
    private static let fullReel = [8,9,0,1,2,3,4,5,6,7,8,9,0,1]
    
    let digit: Int
    let isFraction: Bool
    let reel: [Int]
    
    init (digit: Int, isFraction: Bool) {
        self.digit = digit
        self.isFraction = isFraction
        self.reel = Array(CounterReel.fullReel[digit...digit+4])
    }
}

struct CounterReelView: View {
    
    let counterReel: CounterReel
    let font: Font
    let hOffset: CGFloat
    
    var body: some View {
        ZStack {
            VStack(spacing: -5) {
                Text("\(counterReel.reel[0])").font(font)
                Text("\(counterReel.reel[1])").font(font)
                Text("\(counterReel.reel[2])").font(font)
                Text("\(counterReel.reel[3])").font(font)
                Text("\(counterReel.reel[4])").font(font)
            }
            .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .foregroundColor(counterReel.isFraction ? .black : .white).modifier(ShiftEffect(pct: hOffset))
        }
        .background(Rectangle().fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)))
    }
    
    var gradient: Gradient {
        
        counterReel.isFraction ? Gradient(colors: [Color(UIColor.lightGray), .white, Color(UIColor.lightGray)]) : Gradient(colors: [.black, .gray, .black])
    }
    
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

//        func getUnitDigit(_ number: Double) -> Int {
//            return abs(Int(number) - ((Int(number) / 10) * 10))
//        }
//
//        func getTensDigit(_ number: Double) -> Int {
//            return abs((Int(number) / 10))
//        }
//
//        func getHundredsDigit(_ number: Double) -> Int {
//            return abs(Int(number) / 100)
//        }
//
//        func getThousandsDigit(_ number: Double) -> Int {
//            return abs(Int(number) / 1000)
//        }
//
//        func getOffsetForUnitDigit(_ number: Double) -> CGFloat {
//            return 1 - CGFloat(number - Double(Int(number)))
//        }
//
//        func getOffsetForTensDigit(_ number: Double) -> CGFloat {
//            if getUnitDigit(number) == 0 {
//                return 1 - CGFloat(number - Double(Int(number)))
//            } else {
//                return 0
//            }
//        }
//
//        func getOffsetForHundredsDigit(_ number: Double) -> CGFloat {
//            if (getTensDigit(number) % 10) == 0 {
//                return 1 - CGFloat(number - Double(Int(number)))
//            } else {
//                return 0
//            }
//        }
