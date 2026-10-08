---
name: redis-mastery
description: Use when designing Redis caching, connection pooling, pipeline batching, production ACL/TLS, or LLM semantic caching.
license: MIT
metadata:
  author: Redis, Inc. & ECC Standards
  version: "2.0.0"
---

# Redis Mastery: Core Modeling, Connections, Security & Semantic Cache

Comprehensive production guidance for Redis across backend microservices, real-time caches, and AI workloads.

---

## 1. Core Data Modeling & Key Conventions

Choose the Redis type matching the **access pattern**, not merely the raw shape of data.

| Use Case | Recommended Type | Why & Command Pattern |
|---|---|---|
| Counters, rate-limit keys, simple string cache | **String** | Atomic `INCR`/`DECR`, `SET ex ...`, `GET` |
| Entity with independently updated fields | **Hash** | Per-field reads/writes (`HSET`, `HGET`, `HMGET`), avoids full object serialization |
| Queue, FIFO / LIFO, recent N items | **List** | O(1) push/pop at ends (`LPUSH`, `RPOP`, `LRANGE`) |
| Unique sets, fast membership checks | **Set** | O(1) membership (`SADD`, `SISMEMBER`, `SCARD`) |
| Leaderboards, score rankings, timestamp ranges | **Sorted Set (ZSet)** | Score-ordered indexing (`ZADD`, `ZRANGEBYSCORE`, `ZRANK`) |
| Hierarchical / nested entity models | **JSON** | Native path queries and partial JSON path updates |
| Event log, fan-out messaging, stream ingestion | **Stream** | Persistent streaming with consumer groups (`XADD`, `XREADGROUP`) |

### Key Naming Convention:
Use hierarchical colon-separated format: `{entity}:{id}:{attribute}`
- `user:1001:profile`
- `tournament:2026:leaderboard`
- `match:502:scores`
- Always lowercase, short, descriptive, never embed long raw URLs directly in keys.

---

## 2. Connection Management: Pool & Pipeline

### Never open one connection per HTTP request!
- **Connection Pooling**: Maintain persistent connections leased per request (`redis-py` `ConnectionPool`, `ioredis` multiplexer, `go-redis`).
- **Pipelining (Batching)**: For $N$ independent commands, send them in a single network round-trip via non-transactional pipeline:
  ```typescript
  const pipe = redis.pipeline();
  ids.forEach(id => pipe.get(`item:${id}`));
  const results = await pipe.exec();
  ```
- **Avoid Server-Blocking Commands in Production**:
  - ❌ **NEVER run `KEYS *`** on production (blocks single-threaded engine). Always use `SCAN` with cursor.
  - ❌ Avoid `SMEMBERS` or `HGETALL` on massive sets/hashes. Use `SSCAN` and `HSCAN`.

---

## 3. Production Security & Hardening

1. **Authentication & ACLs**: Disable default user or require strong auth password (`requirepass`). Define scoped ACL users with minimal command access.
2. **Network Isolation**: Ensure `protected-mode yes` and bind only to internal loopback / VPC network interfaces (`127.0.0.1` or internal private IP).
3. **Dangerous Commands Renaming/Disabling**:
   Disable or rename dangerous administrative commands in `redis.conf`:
   ```
   rename-command FLUSHALL ""
   rename-command FLUSHDB ""
   rename-command CONFIG ""
   ```
4. **TLS Encryption**: Use TLS certificates for all cross-server and external Redis connections.

---

## 4. Semantic Caching for AI & LLMs (LangCache)

Use Redis Vector sets or LangCache to eliminate redundant LLM inference costs and latency:
- Hash query prompt embeddings to search existing vector caches with cosine similarity threshold $\ge 0.88 - 0.92$.
- Partition caches by model/task type to avoid cross-domain cache poisoning.
- Always attach TTL to semantic cache entries to prevent stale completions.
