//
//  ContentView.swift
//  Magz
//
//  Created by vikasitha herath on 2023-07-15.
//

import SwiftUI
import WebKit
import UIKit

struct ContentView: View {
    @State private var searchText = ""
    @State private var isDarkMode = false
    @State private var favorites: [Magazine] = []

    var body: some View {
        NavigationView {
            ScrollView {
                SearchBar(text: $searchText)

                Toggle(isOn: $isDarkMode, label: {
                    Text("Dark Mode")
                })
                .padding()

                LazyVGrid(columns: [GridItem(.flexible())], spacing: 26) {
                    ForEach(filteredMagazines) { magazine in
                        NavigationLink(destination: MagazineDetailView(magazine: magazine, isFavorite: favorites.contains(where: { $0.id == magazine.id }), favorites: $favorites)) {
                            MagazineCardView(magazine: magazine)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Magazine")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoriteView(favorites: favorites)) {
                        Image(systemName: "heart.fill")
                    }
                }
            }
        }
    }

    private var filteredMagazines: [Magazine] {
        if searchText.isEmpty {
            return magazines
        } else {
            return magazines.filter { magazine in
                magazine.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct MagazineCardView: View {
    var magazine: Magazine

    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = magazine.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 300)
            } else {
                Color.gray
                    .frame(height: 400)
            }

            Text(magazine.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 60)

            Text(magazine.location)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 3)
        }
        .padding()
        .background(Color.gray)
        .cornerRadius(10)
        .shadow(radius: 5)
        .preferredColorScheme(.light)
    }
}

struct MagazineDetailView: View {
    var magazine: Magazine
    var isFavorite: Bool
    @Binding var favorites: [Magazine]

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                WebView(url: magazine.url)
                Spacer()
            }

            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    Text(magazine.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(magazine.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Total Visits: \(magazine.totalVisits)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(width: 395, height: 100) // Adjust the width and height as needed
                .background(Color(UIColor.systemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(magazine.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isFavorite {
                        favorites.removeAll { $0.id == magazine.id }
                    } else {
                        favorites.append(magazine)
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    shareMagazine()
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .preferredColorScheme(isFavorite ? .dark : .light) // Auto adjust background color based on dark mode
    }
    
    func shareMagazine() {
        guard let url = magazine.url else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            // For iPad support
            activityViewController.popoverPresentationController?.barButtonItem = rootViewController.navigationItem.rightBarButtonItems?.last
            
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

struct FavoriteView: View {
    var favorites: [Magazine]

    var body: some View {
        List(favorites) { magazine in
            NavigationLink(destination: MagazineDetailView(magazine: magazine, isFavorite: true, favorites: .constant(favorites))) {
                Text(magazine.title)
            }
        }
        .navigationBarTitle("Favorites")
    }
}

struct Magazine: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let totalVisits: String
    let imageURL: URL?
    let url: URL?
    
    init(title: String, location: String, totalVisits: String, imageURL: URL?, url: URL?) {
        self.title = title
        self.location = location
        self.totalVisits = totalVisits
        self.imageURL = imageURL
        self.url = url
    }
}

let magazines: [Magazine] = [
    Magazine(title: " T: The New York   Times Magazine", location: "New York, NY", totalVisits: "569,379,567", imageURL: URL(string: "https://mcpl.info/sites/default/files/Pictures/nyt.jpg"), url: URL(string: "https://www.nytimes.com/international/")),
        Magazine(title: "The New York Times Style Magazine", location: "New York, NY", totalVisits: "569,379,567", imageURL: URL(string: "https://1000logos.net/wp-content/uploads/2017/04/Symbol-New-York-Times.png"), url: URL(string: "https://www.nytimes.com/section/t-magazine")),
        Magazine(title: "Observer Magazine", location: "New York, NY", totalVisits: "569,379,567", imageURL: URL(string: "https://i.guim.co.uk/img/static/sys-images/Guardian/Pix/pictures/2011/7/30/1312024506174/Lord-Mountbatten-001.jpg?width=300&quality=85&auto=format&fit=max&s=1a08dfd4cf0a411ea468e9a0a6bebe71"), url: URL(string: "https://www.theguardian.com/theobserver/magazine")),
        Magazine(title: "Observer design Magazin", location: "London, United Kingdom", totalVisits: "350,579,614", imageURL: URL(string: "https://gujims.com/media/cache/image/uploads/assets/ba312dd97e1b943cb85cd7e9c628850ec20c698a.png"), url: URL(string: "https://www.theguardian.com/lifeandstyle/series/observer-design")),
        Magazine(title: "People Magazine", location: "New York, NY", totalVisits: "147,412,170", imageURL: URL(string: "https://www.shespeaks.com/pages/img/review/people_06092010160503.jpg"), url: URL(string: "https://people.com")),
        Magazine(title: "Yo Dona", location: "Madrid, Spain", totalVisits: "143,803,910", imageURL: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9pGZrtBpQI00ED24BGjcdVeTtsLtYYeqeKq6QyF6IcyppbUYbRlWu6mvqT8t5vskzH4M&usqp=CAU"), url: URL(string: "https://www.elmundo.es/yodona.html")),
            Magazine(title: "d la Repubblica", location: "Rome, Italy", totalVisits: "137,386,010", imageURL: URL(string: "https://fashionfav.com/wp-content/uploads/2018/12/Lou-Doillon-Covers-D-Repubblica-Magazine-September-2018-800x1000.jpg"), url: URL(string: "https://www.repubblica.it/moda-e-beauty/d/")),
            Magazine(title: "Mareena Magazine", location: "Sulawesi, Indonesia", totalVisits: "137,009,645", imageURL: URL(string: "https://pbs.twimg.com/media/A5Zu3uuCEAAdQ0O.jpg"), url: URL(string: "https://medium.com/mareenamagz")),
    // Add more magazines here...
]

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)

            Button(action: {
                text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(.systemGray3))
                    .padding(.trailing, 8)
            }
            .opacity(text.isEmpty ? 0 : 1)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
