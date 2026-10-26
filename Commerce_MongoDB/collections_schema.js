/**
 * QueryQuest: NoSQL Database Design (Commerce System)
 * Database: MongoDB Atlas
 * Focus: High-write throughput and flexible schema for e-commerce.
 */

// ==============================================================================
// Collection 1: Users
// Focus: Fast read access for authentication and profile management.
// ==============================================================================
db.createCollection("users", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: [ "email", "passwordHash", "createdAt" ],
         properties: {
            email: {
               bsonType: "string",
               description: "must be a string and is required"
            },
            passwordHash: {
               bsonType: "string",
               description: "hashed password, required"
            },
            // Shipping addresses are embedded. 
            // In a relational DB this would be a separate table.
            // In NoSQL, embedding it here prevents expensive JOINs during checkout.
            addresses: {
               bsonType: "array",
               items: {
                  bsonType: "object",
                  properties: {
                     street: { bsonType: "string" },
                     city: { bsonType: "string" },
                     zip: { bsonType: "string" }
                  }
               }
            },
            createdAt: { bsonType: "date" }
         }
      }
   }
});

// Create unique index on email
db.users.createIndex({ email: 1 }, { unique: true });


// ==============================================================================
// Collection 2: Products
// Focus: Read-heavy, requires rich querying (faceted search).
// ==============================================================================
db.createCollection("products", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name", "price", "stockQuantity"],
            properties: {
                name: { bsonType: "string" },
                description: { bsonType: "string" },
                price: { bsonType: "decimal" },
                stockQuantity: { bsonType: "int" },
                // The flexible schema allows for dynamic attributes 
                // without altering table structures (unlike SQL).
                attributes: {
                    bsonType: "object",
                    description: "Dynamic attributes like color, size, material"
                }
            }
        }
    }
});


// ==============================================================================
// Collection 3: Orders (High-Write Focus)
// Focus: Scalability for high-volume transactions.
// ==============================================================================
db.createCollection("orders", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["userId", "orderDate", "totalAmount", "status", "items"],
            properties: {
                userId: { bsonType: "objectId", description: "Reference to users collection" },
                orderDate: { bsonType: "date" },
                totalAmount: { bsonType: "decimal" },
                status: { enum: ["Pending", "Processing", "Shipped", "Delivered"] },
                // Items are embedded directly into the order.
                // This guarantees atomic writes when creating an order 
                // (no multi-table transactions needed).
                items: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        required: ["productId", "quantity", "priceAtPurchase"],
                        properties: {
                            productId: { bsonType: "objectId" },
                            quantity: { bsonType: "int" },
                            priceAtPurchase: { bsonType: "decimal" }
                        }
                    }
                }
            }
        }
    }
});

// Sharding Key Strategy Note for High-Write:
// To scale write operations horizontally across multiple servers, we would shard the 'orders' collection.
// A good shard key might be a hashed { userId: 'hashed' } to ensure even distribution of writes across the cluster.
