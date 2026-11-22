# Environments Use Full-Snapshot Revisions

Uploading a dotenv file replaces an Environment with one validated, atomic snapshot rather than merging individual keys. Prior snapshots remain recoverable for up to 30 revisions or 90 days, restores create a new revision, and owners can explicitly purge live history when older values must no longer be recoverable; encrypted backups may retain deleted ciphertext for up to 30 days.
