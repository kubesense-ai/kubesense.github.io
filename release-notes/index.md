# 1.1.0
### ✨ Features and Improvements

- **🤖 AI**
  - 🧠 Added Root Cause Analysis (RCA) for trace-related issues.
  - 📊 DevOps LLM can now generate lists, charts, and tables.

- **🏗️ Infrastructure**
  - 🛠️ Added support for managing Jobs and ConfigMaps on the Infra page.

- **📝 Logs**
  - 🔍 Implemented log highlighting for search terms.

- **🖌️ UX**
  - ⏳ Added a horizontal loader to the top of the filters component.
  - 🗂️ Introduced an issue type filter on the issues page for better filtering.
  - 🔄 Modified the events table to support infinite scroll on the events page and in the infrastructure pod drawer.
  - 🧭 Introduced drawer navigation for easier access to main tables.

- **📦 Workloads**
  - 🎨 Revamped the Workloads UI for a better user experience.
  - 📊 Added PVC metrics to the storage tab in the workload details page.

- **🔐 Auth**
  - 🧑‍💻 Added support for Google Authentication for easier login.

- **💻 UI**
  - ✨ Improved the login page UI for a more polished look.
  - 🌐 **Distributed Tracing**: Users can now view the distributed trace map directly in the trace details drawer.
  - 🔗 Users can access the **Users** and **Settings** pages even when no clusters are configured.

- **🔗 Aggregator**
  - 🔍 Added support for linking logs to traces for better traceability.
  - 🧹 Improved workload name parsing using regex for more accurate identification.

- **📦 ClickHouse**
  - ☁️ Added support for GCP bucket and Azure Blob Storage in ClickHouse.
  - ⚙️ Updated the default storage policy for better performance and resource management.
  Here's a version of the release notes with emojis for versions 1.0.18, 1.0.17, 1.0.16, and 1.0.15:

#### 🐛 Bug Fixes
- **Various stability improvements** to enhance user experience.

--- 

### 1.0.18

#### ✨ Features & Improvements
- 🛡️ **Add Masking**: Mask sensitive data in logs and traces.
- 🔍 **Resource Path Search**: Search by resource path in trace summary view.
- 🗂️ **Service Map Filters**: Added extra filters for tracing connections in the service map.
- 💻 **UI Upgrades**: Improved user interface on workload screens for a better experience.
- 🚀 **Performance Boost**: Optimized metrics scrapper for faster data collection.
- 🔧 **Helm Updates**: Updated Helm values to use global settings for image registry and `pullSecrets`.

---

### 1.0.17

#### ✨ Features & Improvements
- 📊 **Affinity Rules**: Updated affinity rules for ClickHouse to align with other charts.
- 🚀 **PriorityClass**: Added `priorityClass` settings for kubesensor and logsensor for better control.
- 🔧 **Helm Values Update**: Updated Helm values for the aggregator component.
- 🧠 **Auto-Memory Configuration**: ClickHouse now auto-generates `max_memory` and `merges_memory` from resource limits.
- 🧵 **Thread Boost**: Increased `remote_write` threads to 30 in the otel-agent for smoother performance.

---

### 1.0.16

#### ✨ Features & Improvements
- 🚫 **Removed**: Dropped Kubernetes cluster metrics for a cleaner setup.
- ❌ **Redis Disabled**: Redis has been disabled in KubeSense.
- 🤖 **Otel-Agent Enhancements**:
  - 🔑 Updated otel-agent's cluster role permissions for better security.
  - 🕒 Updated scrape interval to **10s** for more frequent data collection.
  - 🌐 Kubelet metrics now reinitiates even when nodes scale down.
- 📊 **Enhanced Filters**: Added a count of available fields in all sidebar filters.
- 📌 **Service Map Upgrade**: Added a dropdown in Service Map connections view to filter for error traces.
- 🔍 **Trace Search**: Added a search bar in Traces Summary to search for `clustered_resource`.

---

### 1.0.15

#### ✨ Features & Improvements
- 🌐 **HTTP Connections**: Updated log aggregator to use HTTP connections instead of gRPC for better compatibility.
- 🔄 **KubeCol Update**: Updated KubeCol version to 1.0.4 for new `entity_last` and `entity_last_local` tables.
- 🤝 **Aggregator**: Added multi-platform support for the aggregator.
- 💪 **ARM64 Support**: Now supports ARM64 images.
- 📈 **HPA Added**: Horizontal Pod Autoscaler (HPA) enabled for KubeCol.
- 🧹 **Cleaner ClickHouse**: Removed `ckissuer` auto-drop for ClickHouse parts when PVC limit is reached.
- 🔒 **Security Context**: Added security context values for logsensor for enhanced security.
- ⚠️ **Panic Log Level**: Included a new panic log level category in the aggregator's parsing logic.

#### 🐛 Bug Fixes
- 🔧 **Fix**: Resolved nodeport issue in `vmagent`.
- 🔄 **Fix**: Fixed otel-agent restarting issue whenever a new node was detected.
- 🩺 **Fix**: Added a health call to the otel-agent for the readiness probe on port 8888.

---
