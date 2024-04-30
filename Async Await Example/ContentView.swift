//
//  ContentView.swift
//  Async Await Example
//
//  Created by Anh Dinh on 3/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var user: GithubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120, height: 120)

            
            Text(user?.login ?? "Hello, world!")
                .bold()
                .font(.system(size: 20))
            
            Text(user?.bio ?? "This is the bio")
                .padding()
            
            Spacer()
            
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidData {
                print("Invalid Data")
            } catch GHError.invalidResponse {
                print("Invalid Response")
            } catch {
                // Phải có thằng catch này ko thì sẽ có error
                print("Unexpected Error")
            }
            
        }
    }
    
    func getUser() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/sallen0400"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        // Syntax mới để networking
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let resonse = response as? HTTPURLResponse, resonse.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            // the JSON variable is snake case then it will convert to camelCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let user = try decoder.decode(GithubUser.self, from: data)
            return user
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GithubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

// Common practice for networking error
enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
