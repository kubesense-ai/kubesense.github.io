# RELEASE 1.0.15
## Updates
1. Updated log aggregator to use http connections instead of grpc
2. Update kubecol version to 1.0.4 to update entity_last & entity_last_local tables
3. Update aggregator to support multi-platform
    * support for arm63 images included
4. Add HPA for kubecol
5. Remove ckissuer auto drop clickhouse parts if pvc has reached its limit
6. Add security context values for logsensor
7. Add panic log level category in aggregator parsing

## Fixes
1. Fix nodeport issue in vmagent
2. Fix otel-agent restarting issue whenever a new node is detected
    * Add health call to otel-agent for readiness probe at port 8888
