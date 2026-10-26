# Evaluated CAP Theorem in NoSQL Architecture

As part of the **QueryQuest** project, we evaluated the **CAP Theorem** to architect a scalable NoSQL backend for the Commerce/E-commerce domain using MongoDB Atlas.

## The CAP Theorem Defined
The CAP theorem states that in any distributed data store, you can only guarantee two of the following three properties simultaneously:
1.  **Consistency (C):** Every read receives the most recent write or an error. All nodes see the same data at the same time.
2.  **Availability (A):** Every request receives a (non-error) response, without the guarantee that it contains the most recent write.
3.  **Partition Tolerance (P):** The system continues to operate despite an arbitrary number of messages being dropped or delayed by the network between nodes.

*Because network partitions (P) are unavoidable in distributed cloud systems, the architectural choice always comes down to choosing between Consistency (CP) and Availability (AP).*

---

## Architectural Decision for Commerce

We chose **MongoDB**, which is fundamentally a **CP (Consistent and Partition Tolerant)** system by default. 

### Why not AP (Availability / Partition Tolerance)?
In a commerce system handling financial transactions, inventory, and user orders, strict eventual consistency (AP) can lead to critical business errors. For example:
*   User A and User B might simultaneously see that 1 item is left in stock (because the read nodes haven't synchronized). 
*   Both purchase it, leading to a negative inventory state.

### How we configured MongoDB (CP) for High-Write Scenarios
MongoDB ensures Consistency by directing all writes to a primary node. If that node fails, a new primary is elected (during which time the system is temporarily unavailable for writes—sacrificing Availability for Consistency).

To handle the **"high-write commerce"** requirement specified in the project goals without creating a bottleneck at the primary node, we implemented the following strategies conceptually:

#### 1. Horizontal Scaling via Sharding
We designed the schema to support sharding. By sharding the `Orders` collection using a hashed key (e.g., `hashed(userId)`), write operations are distributed evenly across multiple physical shards (multiple primary nodes). 
*   **Result:** Massive increase in write-throughput capacity.

#### 2. Tuning Write Concerns (`w`)
MongoDB allows tuning the balance between performance and durability on a per-query basis using Write Concerns.
*   **For critical operations (Payment processing):** `w: "majority"`. The system waits until the write is replicated to a majority of nodes before acknowledging success. High consistency, higher latency.
*   **For non-critical high-volume operations (User clickstream/logging):** `w: 1` or `w: 0`. The system acknowledges the write as soon as it hits memory on the primary node. Lower consistency guarantee, extremely low latency (high performance).

#### 3. Embedded Document Model
As seen in `collections_schema.js`, we embedded `Items` directly inside the `Order` document. In MongoDB, updates to a single document are atomic. By embedding, we ensured that creating an order and its associated items happens in a single, fast, atomic write operation, bypassing the need for complex, slow multi-document transactions.

## Outcome
By understanding the CAP theorem, we successfully designed a MongoDB architecture that prioritizes the structural consistency required for e-commerce, while mitigating the write-bottlenecks of a CP system through sharding and atomic embedded document updates.
