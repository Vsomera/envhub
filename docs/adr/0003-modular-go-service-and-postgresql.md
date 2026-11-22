# Start with a Modular Go Service and PostgreSQL

The first release uses one modular Go service and one PostgreSQL database for relational metadata and encrypted snapshots, with versioned schema migrations and no cache or message queue. This avoids distributed-service and cross-database failure modes while the product is small; hosting remains provider-neutral until operational constraints are known.
