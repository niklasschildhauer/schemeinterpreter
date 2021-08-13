//
//  HashTable.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 10.08.21.
//

import Foundation

//  MARK: Implementation Hash Table
/// This struct is used to store elements in form of a hash table. For each element in the table a key is required
/// which type conforms to the Hashable protocol. In this way for each key a hash value can be created.
/// The hash value is used to find a bucket to store the value in it. This struct contains a array of buckets.
/// A bucket is again a Array of Elements. If two elements key hash value ends up in the same bucket, both elements can be stored in the same bucket.
/// To find an element the keys hash value is used to find the bucket and then in the bucket the element will be searched.
struct HashTable<Key: Hashable, Value> {
    private typealias Element = (key: Key, value: Value)
    private typealias Bucket = [Element]
    private var buckets: [Bucket]
    private var capacity: Int
    private var count = 0
    
    /// returns true if no element is inserted
    var isEmpty: Bool {
        return count == 0
    }
    
    /// returns true if the buckets are full
    var isFull: Bool {
        get {
            return self.capacity * 3 / 4 < count
        }
    }
    
    /// returns the actual count of the elements in the buckets
    var size: Int {
        get {
            return count
        }
    }
    
    /// returns the max capacity
    var maxCapacity: Int {
        get {
            self.capacity
        }
    }

    // MARK: Constructor
    init(capacity: Int) {
        buckets = Array<Bucket>(repeating: [], count: capacity)
        self.capacity = capacity
    }
    
    /// This function uses the index(for key: Key)  Function to get the bucket index. Afterwards
    /// in the bucket the element will be searched.
    /// It returns either the Value or nil
    func value(for key: Key) -> Value? {
        let index = self.index(for: key)
        return buckets[index].first { $0.key == key }?.value
    }
    
    /// This function is used to return all elements in the buckets, so that
    /// a new hash table can be created with the elements
    func getAllElements() -> [Value] {
        var elements: [Value] = []
        for bucket in buckets {
            bucket.forEach { (key, value) in
                elements.append(value)
            }
        }
        
        return elements
    }

    /// Returns the index of a key
    private func index(for key: Key) -> Int {
      return abs(key.hashValue) % buckets.count
    }
    
    /// This function inserts a new element in the hash table
    /// It returns the inserted value
    @discardableResult
    mutating func new(value: Value, for key: Key) -> Value {
        let index = self.index(for: key)
                
        buckets[index].append((key: key, value: value))
        count += 1
    
        return value
    }
    
    /// This function updates the value of a known key
    /// Returns the element or nil if it was not successful
    @discardableResult
    mutating func update(value: Value, for key: Key) -> Value? {
        let index = self.index(for: key)
        for (i, element) in buckets[index].enumerated() {
            if element.key == key {
                buckets[index][i].value = value
                return buckets[index][i].value
            }
        }

        return nil
    }
}



