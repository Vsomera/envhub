# Use Server-Side Envelope Encryption

Environment snapshots are envelope-encrypted with keys managed outside the database, and the service decrypts only for authenticated, authorized pulls. This favors a straightforward CLI workflow over end-to-end encryption, so service-side authorization, secret redaction, and protected transport are mandatory; loss of every recoverable managed-key version means the encrypted data cannot be recovered.
