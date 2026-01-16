import SwiftUI

// MARK: - 1. Yeni Neo Renkleri
extension Color {
    static let neoLime = Color(hex: "D1D815")   // Katıl / The Nomad
    static let neoOrange = Color(hex: "F7931E") // Bireysel / The Hype
    static let neoPurple = Color(hex: "B61AFF") // Şirket / The Brain
    static let neoRed = Color(hex: "FF183A")    // Oluştur / The Ghost / Alert
}

// MARK: - 2. Tasarım Dili (Refined Neo-Brutalist Modifier)
// İnce kenarlık (2px), sert gölge, keskin köşe
struct NeoCardStyle: ViewModifier {
    var color: Color
    var strokeWidth: CGFloat = 2
    var shadowOffset: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(color)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: strokeWidth)
            )
            .background(
                Rectangle()
                    .fill(Color.black)
                    .offset(x: shadowOffset, y: shadowOffset)
            )
            .padding(.trailing, shadowOffset)
            .padding(.bottom, shadowOffset)
    }
}

extension View {
    func neoStyle(color: Color) -> some View {
        self.modifier(NeoCardStyle(color: color))
    }
}

// MARK: - 3. Ana Ekran (Dashboard)
struct HomeDashboardView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var teamService = TeamService.shared
    
    // Test için değişkenler
    @State var isTestCompleted: Bool = true
    
    // Kullanıcı verisi
    var userName: String {
        authService.currentUser?.username ?? authService.currentUser?.fullName ?? "Kullanıcı"
    }
    
    var hasJoinedCompany: Bool {
        authService.currentUser?.teamId != nil
    }
    
    let userPersona = "THE BRAIN"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    statusSection
                    panelHubSection
                    smartDeskSection
                    discoverySection
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(Color.white.ignoresSafeArea())
        }
    }
    
    // MARK: - BÖLÜM 1: Header
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Merhaba,")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                Text("\(userName)!")
                    .font(.largeTitle)
                    .fontWeight(.black)
            }
            
            Spacer()
            
            // Logout Button
            Button(action: {
                AuthService.shared.signOut()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
            }
            .padding(.trailing, 8)
            
            // Persona Badge
            if isTestCompleted {
                ZStack {
                    Circle()
                        .fill(Color.neoPurple)
                        .frame(width: 50, height: 50)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }
        }
    }
    
    // MARK: - BÖLÜM 2: Status Bar
    var statusSection: some View {
        HStack {
            Image(systemName: isTestCompleted ? "bolt.fill" : "exclamationmark.triangle.fill")
            Text(isTestCompleted
                 ? "Bugün modun: Analitik zekan tavan yapmış! 🧠"
                 : "Ofis karakterini henüz belirlemedin. Teste başla 👉")
                .font(.footnote)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
    }
    
    // MARK: - BÖLÜM 3: Panel Hub (Conditional)
    var panelHubSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OFİS BAĞLANTILARI")
                .font(.caption)
                .fontWeight(.black)
                .foregroundColor(.gray)
            
            if hasJoinedCompany {
                // Mevcut Kullanıcı - Panelleri Göster
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Şirket Paneli - MainTabView'a yönlendir
                        NavigationLink(destination: MainTabView()) {
                            PanelCard(
                                title: teamService.currentTeam?.name ?? "Şirket",
                                subtitle: "Şirket Paneli",
                                icon: "building.2.fill",
                                color: .neoPurple
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Bireysel Panel - IndividualChecklistScreen'e yönlendir
                        NavigationLink(destination: IndividualChecklistScreen(selectedTab: .constant(1))) {
                            PanelCard(
                                title: "Kişisel Alan",
                                subtitle: "Bireysel Panel",
                                icon: "person.fill",
                                color: .neoOrange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Ekleme Butonu
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title)
                            }
                            .frame(width: 80, height: 100)
                            .background(Color.white)
                            .overlay(Rectangle().stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5])))
                        }
                        .foregroundColor(.black)
                    }
                }
            } else {
                // Yeni Kullanıcı - Oluştur/Katıl
                HStack(spacing: 15) {
                    NavigationLink(destination: CreateTeamScreen()) {
                        ActionCard(title: "Şirket Oluştur", icon: "plus.square.fill.on.square.fill", color: .neoRed, textColor: .white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: JoinTeamScreen()) {
                        ActionCard(title: "Ekibe Katıl", icon: "link", color: .neoLime, textColor: .black)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - BÖLÜM 4: Smart Desk (Widget)
    var smartDeskSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BENİM MASAM")
                .font(.caption)
                .fontWeight(.black)
                .foregroundColor(.gray)
            
            ZStack {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    DeskWidget(icon: "chart.bar.fill", title: "İstatistik", color: .white)
                    DeskWidget(icon: "list.bullet.clipboard", title: "Raporlar", color: .white)
                    DeskWidget(icon: "calendar.badge.clock", title: "Toplantılar", color: .white)
                    DeskWidget(icon: "bell.badge.fill", title: "Duyurular", color: .white)
                }
                
                // Yeni kullanıcıysa kilitli görünüm
                if !hasJoinedCompany {
                    Color.white.opacity(0.8)
                        .blur(radius: 2)
                    
                    VStack {
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                            .padding(.bottom, 5)
                        Text("Masanı kurmak için\nbir ekibe katıl.")
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    // MARK: - BÖLÜM 5: Footer (Discovery)
    var discoverySection: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Base of Office Nedir?")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Simülasyon modunda test et ve öğren.")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "gamecontroller.fill")
                    .font(.largeTitle)
            }
            .foregroundColor(.black)
        }
        .neoStyle(color: .white)
        .onTapGesture {
            print("Simülasyon Modu Açılıyor...")
        }
    }
}

// MARK: - YARDIMCI GÖRÜNÜMLER (Components)

struct PanelCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: icon)
                .font(.title2)
                .padding(.bottom, 10)
            Spacer()
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
            Text(subtitle)
                .font(.caption)
                .opacity(0.8)
        }
        .foregroundColor(color == .neoRed || color == .neoPurple ? .white : .black)
        .padding()
        .frame(width: 160, height: 120)
        .background(color)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .background(
            Rectangle()
                .fill(Color.black)
                .offset(x: 4, y: 4)
        )
        .padding(.trailing, 4)
        .padding(.bottom, 4)
    }
}

struct ActionCard: View {
    var title: String
    var icon: String
    var color: Color
    var textColor: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .padding(.bottom, 5)
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
        }
        .foregroundColor(textColor)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(color)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .background(
            Rectangle()
                .fill(Color.black)
                .offset(x: 4, y: 4)
        )
        .padding(.trailing, 4)
        .padding(.bottom, 4)
    }
}

struct DeskWidget: View {
    var icon: String
    var title: String
    var color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .padding(.bottom, 5)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(color)
        .overlay(Rectangle().stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5])))
    }
}

// MARK: - Önizleme (Preview)
#Preview("Dolu Profil") {
    HomeDashboardView(isTestCompleted: true)
}

#Preview("Yeni Kullanıcı") {
    HomeDashboardView(isTestCompleted: false)
}
