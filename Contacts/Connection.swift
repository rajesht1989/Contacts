//
//  Connection.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 01/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import Foundation

struct Contact: Codable, Hashable {
    let id: Int
    let firstName, lastName, profilePic: String
    var favorite: Bool
    let email: String?
    let phoneNumber: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
        case phoneNumber = "phone_number"
        case favorite, url, id, email
    }
}

struct MutableContact {
    var firstName, lastName, email, phoneNumber: String?
}

enum ContactsError: Error {
    case error(String)
    public var errorDescription: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

typealias SortedContacts = [Contact]
typealias GroupedContacts = [String: [Contact]]
typealias SortedAlphabets = [String]
typealias ContactsCompletion = ((SortedContacts, GroupedContacts, SortedAlphabets)?, Error?) -> Void
typealias ImageCompletion = ((Data,Contact)?, Error?) -> Void
typealias DeleteCompletion = (Error?) -> Void
typealias ContactCompletion = (Contact?, Error?) -> Void


class Connection {
    static func decodeUrl(string: String) -> String {
        return string.replacingOccurrences(of: "z", with: "o").replacingOccurrences(of: "y", with: "e")
    }
    
    static let baseUrl = decodeUrl(string: "http://gzjyk-czntacts-app.herokuapp.com")
    
    static func contacts(completion: @escaping ContactsCompletion) {
        let urlComponents = URLComponents(string: baseUrl.appending("/contacts.json"))
        URLSession.shared.dataTask(with: urlComponents!.url!) { (data, response, err) in
            if let jsonData = data {
                do {
                    let contacts = try JSONDecoder().decode([Contact].self, from: jsonData).sorted(by: { $0.firstName < $1.firstName })
                    if contacts.count > 0 {
                        let groupedContacts = Dictionary(grouping: contacts, by: { String($0.firstName.uppercased().first!) })
                        let sortedContacts = groupedContacts.keys.sorted(by: { $0 < $1 })
                        DispatchQueue.main.async {
                            completion((contacts, groupedContacts, sortedContacts), nil)
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                return
            }
            DispatchQueue.main.async { completion(nil, err) }
        }.resume()
    }
    
    static func image(for contact: Contact, completion: @escaping ImageCompletion) {
        if let data = UserDefaults.standard.data(forKey: contact.profilePic) {
            completion((data, contact), nil)
        } else {
            let urlComponents = URLComponents(string: baseUrl.appending(contact.profilePic))
            URLSession.shared.dataTask(with: urlComponents!.url!) { (data, response, err) in
                if let imageData = data {
                    UserDefaults.standard.set(imageData, forKey: contact.profilePic)
                    DispatchQueue.main.async {
                        completion((imageData, contact) , nil)
                    }
                    return
                }
                DispatchQueue.main.async { completion(nil, err) }
            }.resume()
        }
    }
    
    static func delete(_ contact: Contact, completion: @escaping DeleteCompletion) {
        let urlComponents = URLComponents(string: baseUrl.appending("/contacts/").appending(String(contact.id)).appending(".json"))
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            DispatchQueue.main.async { completion(err) }
        }.resume()
    }
    
    static func connect(_ request: URLRequest, completion: @escaping ContactCompletion) {
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let jsonData = data {
                do {
                    if let contact = try? JSONDecoder().decode(Contact.self, from: jsonData) {
                        DispatchQueue.main.async { completion(contact, nil) }
                    } else {
                        if let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: [String]] {
                            throw ContactsError.error(json["errors"]?.joined(separator: ", ") ?? "Unknown Error")
                        } else {
                            throw ContactsError.error(String(data: jsonData, encoding: .utf8) ??  "Unknown Error")
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                return
            }
            DispatchQueue.main.async { completion(nil, err) }
        }.resume()
    }
    
    static func contactDetails(_ contactId: Int, completion: @escaping ContactCompletion) {
        let urlComponents = URLComponents(string: baseUrl.appending("/contacts/").appending(String(contactId)).appending(".json"))
        connect(URLRequest(url: (urlComponents?.url)!), completion: completion)
    }
    
    static func inverseFavorite(_ contact: Contact, completion: @escaping ContactCompletion) {
        let urlComponents = URLComponents(string: baseUrl.appending("/contacts/").appending(String(contact.id)).appending(".json"))
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["favorite":!contact.favorite])
        connect(request, completion: completion)
    }
    
    static func update(_ contactId: Int, contact: MutableContact, completion: @escaping ContactCompletion) {
        let urlComponents = URLComponents(string: baseUrl.appending("/contacts/").appending(String(contactId)).appending(".json"))
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["first_name": contact.firstName!, "last_name": contact.lastName!, "email": contact.email!,"phone_number": contact.phoneNumber!])
        connect(request, completion: completion)
    }
    
    static func addContact(_ contact: MutableContact, completion: @escaping ContactCompletion) {
        let urlComponents = URLComponents(string: baseUrl.appending("/contacts.json"))
        var request = URLRequest(url: (urlComponents?.url)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["first_name": contact.firstName!, "last_name": contact.lastName!, "email": contact.email!,"phone_number": contact.phoneNumber!])
        connect(request, completion: completion)
    }
}
