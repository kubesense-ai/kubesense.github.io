# 1.0.16
## Features & Improvements
1. Remove k8s cluster metrics
1. Disabled redis in kubesense
1. Otel-agent
   * Update otel cluster role permission with the 
   * Update scrape interval to 10s in otel agent
   * kubelet metrics reinitiates even when a node scales down
1. Add count of available fields in all sidebar filters 
1. Add dropdown in Service map connections view where a user can select only error traces(Service Map) 
1. Add search bar in Traces Summary to search on clustered_resource(Traces Summary)

# 1.0.15
## Features & Improvements
1. Updated log aggregator to use http connections instead of grpc
2. Update kubecol version to 1.0.4 to update entity_last & entity_last_local tables
3. Update aggregator to support multi-platform
    * support for arm64 images included
4. Add HPA for kubecol
5. Remove ckissuer auto drop clickhouse parts if pvc has reached its limit
6. Add security context values for logsensor
7. Add panic log level category in aggregator parsing

## Fixes
1. Fix nodeport issue in vmagent
2. Fix otel-agent restarting issue whenever a new node is detected
    * Add health call to otel-agent for readiness probe at port 8888

