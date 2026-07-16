import SwiftUI

// MARK: - HeroGameTile
struct HeroGameTile: View {
    let mode: GameMode
    let destination: AnyView
    let highScore: Int

    var body: some View {
        NavigationLink(destination: destination) {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { geo in
                    Image(mode.imageName + "_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                
                LinearGradient(
                    colors: [.black.opacity(0.15), .black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Image(mode.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1.5)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("HIGH SCORE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black, radius: 2, y: 1)
                                .shadow(color: .black, radius: 4, y: 2)
                            Text("\(highScore)")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, y: 1)
                                .shadow(color: .black, radius: 4, y: 2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode.rawValue)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, y: 1)
                            .shadow(color: .black, radius: 4, y: 2)
                        Text(mode.subtitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: .black, radius: 2, y: 1)
                            .shadow(color: .black, radius: 4, y: 2)
                    }
                    
                    HStack {
                        Text("PLAY NOW")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(mode.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(24)
            }
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 6)
            .contentShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GridGameTile: View {
    let mode: GameMode
    let destination: AnyView
    let highScore: Int

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Image(mode.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 3, y: 1.5)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black, radius: 2, y: 1)
                        .shadow(color: .black, radius: 4, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, y: 1)
                        .shadow(color: .black, radius: 4, y: 2)
                        .lineLimit(1)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(highScore)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, y: 1)
                            .shadow(color: .black, radius: 4, y: 2)
                        Text("PTS")
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .foregroundColor(mode.accentColor)
                            .shadow(color: .black, radius: 2, y: 1)
                            .shadow(color: .black, radius: 4, y: 2)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    GeometryReader { geo in
                        Image(mode.imageName + "_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                    
                    LinearGradient(
                        colors: [.black.opacity(0.15), .black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
