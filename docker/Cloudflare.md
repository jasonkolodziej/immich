# Notes

Microservices

The Immich Microservices image uses the same Dockerfile as the Immich Server, but with a different entrypoint. The Immich Microservices service mainly handles executing jobs, which include the following:

- Thumbnail Generation
- Metadata Extraction
- Video Transcoding
- Smart Search
- Facial Recognition
- Storage Template Migration
- Sidecar (see XMP Sidecars)
- Background jobs (file deletion, user deletion)
