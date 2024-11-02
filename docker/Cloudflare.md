# Immich Notes

## Cloudflare lingo

- [x] Includes monthly usage

### Workers & Pages Functions

- [x] Up to 15 minutes of CPU time per request

### KV

- [x] Global low-latency key-value edge storage

### Durable Objects

- [x] Low-latency coordination across multiple Workers
- [x] Strongly consistent key-value edge storage

### Queues

- [x] Reliably send and receive messages globally

### Hyperdrive

- [x] Connect to and speed up your existing databases from Workers

## [Microservices](https://immich.app/docs/developer/architecture#microservices)

> **Usage**: `redis` - Defined as Queue management for `immich-microservices` - Execute background jobs (thumbnail generation, metadata extraction, transcoding, etc.)

The Immich Microservices image uses the same Dockerfile as the Immich Server, but with a different entrypoint. The Immich Microservices service mainly handles executing jobs, which include the following:

- Thumbnail Generation
- Metadata Extraction
- Video Transcoding
- Smart Search
- Facial Recognition
- Storage Template Migration
- Sidecar (see XMP Sidecars)
- Background jobs (file deletion, user deletion)

> Note: these Microservices resemble `Workers` utilizing `Durable Objects`
