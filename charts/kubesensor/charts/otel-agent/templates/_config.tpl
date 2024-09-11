{{/*
Default memory limiter configuration for OpenTelemetry Collector based on k8s resource limits.
*/}}

{{/*
Merge user supplied config into memory limiter config.
*/}}
{{- define "otel-agent.baseConfig" -}}
{{- $processorsConfig := get .Values.config "processors" }}
{{- if .Values.useGOMEMLIMIT }}
  {{- if (((.Values.config).service).extensions) }}
    {{- $_ := set .Values.config.service "extensions" (without .Values.config.service.extensions "memory_ballast") }}
  {{- end}}
  {{- $_ := unset (.Values.config.extensions) "memory_ballast" }}
{{- else }}
  {{- $memoryBallastConfig := get .Values.config.extensions "memory_ballast" }}
  {{- if or (not $memoryBallastConfig) (not $memoryBallastConfig.size_in_percentage) }}
  {{-   $_ := set $memoryBallastConfig "size_in_percentage" 40 }}
  {{- end }}
{{- end }}
extensions:
  # The health_check extension is mandatory for this chart.
  # Without the health_check extension the collector will fail the readiness and liveliness probes.
  # The health_check extension can be modified, but should never be removed.
  health_check:
    endpoint: ${env:MY_POD_IP}:13133
  pprof:
    endpoint: :1888
  zpages:
    endpoint: :55679
receivers:
  kubesensek8sevents:
    cluster: "{{ .Values.global.cluster_name }}"
    entities:
      - name: events
        mode: watch
  kubesensestats:
    collection_interval: 10s
    auth_type: "serviceAccount"
    endpoint: https://10.128.15.208:10250
    insecure_skip_verify: true
    metric_groups:
    - container
    - pod
    - volume
    - node
    extra_metadata_labels:
      - container.id
    k8s_api_config:
      auth_type: serviceAccount
  # k8s_cluster:
  #   collection_interval: 10s
  #   node_conditions_to_report: [Ready, MemoryPressure,DiskPressure,NetworkUnavailable]
  #   allocatable_types_to_report: [cpu, memory, storage, ephemeral-storage]
  #   auth_type: serviceAccount

  prometheus:
    config:
      scrape_configs:
        - job_name: ksm-metrics
          scrape_interval: 10s
          metrics_path: /metrics
          static_configs:
            - targets: ["kubesense-kube-state-metrics:8080"]
          relabel_configs:
            - source_labels: []
              target_label: 'clusterId'
              replacement: {{ .Values.global.cluster_name }}
          metric_relabel_configs:
            - source_labels: [node]
              target_label: k8s_node_name
            - source_labels: [pod]
              action: replace
              target_label: workload
              regex: '^(.*?)-[a-fA-F0-9]{7,8}-[a-zA-Z0-9]{4,5}$|^(.*?)-\d+-[a-zA-Z0-9]+$|^(.*?)-[a-fA-F0-9]{9,10}-[a-zA-Z0-9]{4,5}$|(.+)-[^-]+$'
              replacement: '$${1}$${2}$${3}$${4}'


            # First block adds ckubesense prefix to all the label 
            - action: replace
              source_labels: [__name__]
              regex: '(.*)'
              target_label: __name__
              replacement: kubesense_$${1}

              
            # Second block filters out resource limits and tag cpu and memory
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_pod_container_resource_limits;cpu'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_cpu_limit_m_cpu'
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_pod_container_resource_limits;memory'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_memory_limit_bytes'      


            # Third block filters out resource request and tag cpu and memory
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_pod_container_resource_requests;cpu'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_cpu_request_m_cpu'
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_pod_container_resource_requests;memory'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_memory_request_bytes' 


            # Fourth block filters out resource node cpu and memory
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_node_status_allocatable;cpu'
              action: replace
              target_label: __name__
              replacement: 'kubesense_node_allocatable_cpum_cpu'
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_node_status_allocatable;memory'
              action: replace
              target_label: __name__
              replacement: 'kubesense_node_allocatable_mem_bytes'


            # Fifth block filters out resource node cpu and memory
            - source_labels: [__name__,resource]
              regex: 'kubesense_kube_node_status_capacity;ephemeral_storage'
              action: replace
              target_label: __name__
              replacement: 'kubesense_node_disk_space_total_bytes'
            # - source_labels: [__name__,resource]
            #   regex: 'kubesense_kube_node_status_allocatable;memory'
            #   action: replace
            #   target_label: __name__
            #   replacement: 'kubesense_node_allocatable_mem_bytes'   


        # Scrape cAdvisor metrics
        - job_name: integrations/kubernetes/cadvisor
          scrape_interval: 10s
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          kubernetes_sd_configs:
            - role: node
          scheme: https
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            insecure_skip_verify: false
            server_name: kubernetes            
          relabel_configs:
            - source_labels: []
              target_label: 'clusterId'
              replacement: {{ .Values.global.cluster_name }}
            - replacement: kubernetes.default.svc.cluster.local:443
              target_label: __address__
            - regex: (.+)
              replacement: /api/v1/nodes/$${1}/proxy/metrics/cadvisor
              source_labels:
                - __meta_kubernetes_node_name
              target_label: __metrics_path__
          metric_relabel_configs:
            # - source_labels: [instance]
            #   target_label: k8s_node_name
            - source_labels: [pod]
              action: replace
              target_label: workload
              regex: '^(.*?)-[a-fA-F0-9]{7,8}-[a-zA-Z0-9]{4,5}$|^(.*?)-\d+-[a-zA-Z0-9]+$|^(.*?)-[a-fA-F0-9]{9,10}-[a-zA-Z0-9]{4,5}$|(.+)-[^-]+$'
              replacement: '$${1}$${2}$${3}$${4}'


            # container cpu usage seconds total  
            - source_labels: [__name__]
              regex: 'container_cpu_usage_seconds_total'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_m_cpu_usage_seconds_total'
            - source_labels: [__name__]
              regex: 'container_memory_working_set_bytes'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_mem_working_set_bytes'  
            - source_labels: [__name__]
              regex: 'container_cpu_cfs_throttled_seconds_total'
              action: replace
              target_label: __name__
              replacement: 'kubesense_container_cpu_throttled_seconds_total'


        # Scrape kublet metrics
        - job_name: integrations/kubernetes/kubelet
          scrape_interval: 10s
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          kubernetes_sd_configs:
            - role: node
          relabel_configs:
            - source_labels: []
              target_label: 'clusterId'
              replacement: {{ .Values.global.cluster_name }}
            - replacement: kubernetes.default.svc.cluster.local:443
              target_label: __address__
            - regex: (.+)
              replacement: /api/v1/nodes/$${1}/proxy/metrics
              source_labels:
                - __meta_kubernetes_node_name
              target_label: __metrics_path__
          scheme: https
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            insecure_skip_verify: false
            server_name: kubernetes
          metric_relabel_configs:
            - source_labels: [__name__]
              regex: 'kubelet_volume_stats_available_bytes'
              action: replace
              target_label: __name__
              replacement: 'kubesense_pvc_available_bytes'
            - source_labels: [__name__]
              regex: 'kubelet_volume_stats_capacity_bytes'
              action: replace
              target_label: __name__
              replacement: 'kubesense_pvc_capacity_bytes'  
            - source_labels: [__name__]
              regex: 'kubelet_volume_stats_used_bytes'
              action: replace
              target_label: __name__
              replacement: 'kubesense_pvc_usage_bytes'   
          
        # Scrape config for API servers
        # - job_name: "kubernetes-apiservers"
        #   kubernetes_sd_configs:
        #     - role: endpoints
        #       namespaces:
        #         names:
        #           - default
        #   scheme: https
        #   tls_config:
        #     ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        #     insecure_skip_verify: true
        #   bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        #   relabel_configs:
        #     - source_labels: []
        #       target_label: 'clusterId'
        #       replacement: {{ .Values.global.cluster_name }}
        #     - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        #       action: keep
        #       regex: kubernetes;https
        #     - action: replace
        #       source_labels:
        #       - __meta_kubernetes_namespace
        #       target_label: Namespace
        #     - action: replace
        #       source_labels:
        #       - __meta_kubernetes_service_name
        #       target_label: Service  

exporters:
  otlp:
    # refer _config.yaml for templating this is kept as default values
    endpoint: "{{ .Values.global.kubeAggregatorIp }}:{{ .Values.global.nodePort.kubeAggregatorGrpcPort }}"
    tls:
      insecure: true
  prometheusremotewrite:
    endpoint: "{{ if $.Values.global.externalVictoriaMetrics.enabled }}{{ $.Values.global.externalVictoriaMetrics.url }}{{ else }}http://{{ .Values.global.vmAgentIp }}:{{ .Values.global.vmAgentHttpPort }}{{ end }}/api/v1/write"
    resource_to_telemetry_conversion:
      enabled: true
    timeout: 30s
    remote_write_queue:
      enabled: true
      num_consumers: 30
    send_metadata: true
  debug:
    verbosity: detailed
    sampling_initial: 5
    sampling_thereafter: 200
processors:
  filter:
    metrics:
      include:
        match_type: regexp
        metric_names:
          - ".*kubesense.*"
  batch: {}
  # If set to null, will be overridden with values based on k8s resource limits
  metricstransform:
    transforms:
      - include: k8s.node.filesystem.usage
        match_type: strict
        action: insert
        new_name: kubesense.node.disk_space.used_bytes
        operations: 
          - action: add_label
            new_label: clusterId
            new_value: {{ .Values.global.cluster_name }}
      - include: k8s.node.memory.working_set
        match_type: strict
        action: insert
        new_name: kubesense.node.mem.working_set_bytes   
        operations: 
          - action: add_label
            new_label: clusterId
            new_value: {{ .Values.global.cluster_name }}     
      - include: k8s.node.cpu.time
        match_type: strict
        action: insert
        new_name: kubesense.node.m_cpu.usage_seconds_total
        operations: 
          - action: add_label
            new_label: clusterId
            new_value: {{ .Values.global.cluster_name }}
  # experimental_metricsgeneration:
  #   rules:
  #     - name: kubesense.node.disk_space.used_percent
  #       type: calculate
  #       metric1: k8s.node.filesystem.usage
  #       metric2: k8s.node.filesystem.capacity
  #       operation: percent
service:
  telemetry:
    logs:
      level: debug
  pipelines:
    metrics:
      receivers: [kubesensestats,prometheus]
      processors: [batch, metricstransform, filter]
      exporters: [prometheusremotewrite]
    logs:
      receivers: [kubesensek8sevents]
      processors: [batch]
      exporters: [otlp]
{{- end }}

{{/*
Build config file for daemonset OpenTelemetry Collector
*/}}
{{- define "otel-agent.daemonsetConfig" -}}
{{- $values := deepCopy .Values }}
{{- $data := dict "Values" $values | mustMergeOverwrite (deepCopy .) }}
{{- $config := include "otel-agent.baseConfig" $data | fromYaml }}
{{- if .Values.presets.logsCollection.enabled }}
{{- $config = (include "otel-agent.applyLogsCollectionConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.hostMetrics.enabled }}
{{- $config = (include "otel-agent.applyHostMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubeletMetrics.enabled }}
{{- $config = (include "otel-agent.applyKubeletMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubernetesAttributes.enabled }}
{{- $config = (include "otel-agent.applyKubernetesAttributesConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.clusterMetrics.enabled }}
{{- $config = (include "otel-agent.applyClusterMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{/*
Build config file for deployment OpenTelemetry Collector
*/}}
{{- define "otel-agent.deploymentConfig" -}}
{{- $values := deepCopy .Values }}
{{- $data := dict "Values" $values | mustMergeOverwrite (deepCopy .) }}
{{- $config := include "otel-agent.baseConfig" $data | fromYaml }}
{{- if .Values.presets.logsCollection.enabled }}
{{- $config = (include "otel-agent.applyLogsCollectionConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.hostMetrics.enabled }}
{{- $config = (include "otel-agent.applyHostMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubeletMetrics.enabled }}
{{- $config = (include "otel-agent.applyKubeletMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubernetesAttributes.enabled }}
{{- $config = (include "otel-agent.applyKubernetesAttributesConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubernetesEvents.enabled }}
{{- $config = (include "otel-agent.applyKubernetesEventsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.clusterMetrics.enabled }}
{{- $config = (include "otel-agent.applyClusterMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{- define "otel-agent.applyHostMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "otel-agent.hostMetricsConfig" .Values | fromYaml) .config }}
{{- $_ := set $config.service.pipelines.metrics "receivers" (append $config.service.pipelines.metrics.receivers "hostmetrics" | uniq)  }}
{{- $config | toYaml }}
{{- end }}

{{- define "otel-agent.hostMetricsConfig" -}}
receivers:
  hostmetrics:
    root_path: /hostfs
    collection_interval: 10s
    scrapers:
        cpu:
        load:
        memory:
        disk:
        filesystem:
          exclude_mount_points:
            mount_points:
              - /dev/*
              - /proc/*
              - /sys/*
              - /run/k3s/containerd/*
              - /var/lib/docker/*
              - /var/lib/kubelet/*
              - /snap/*
            match_type: regexp
          exclude_fs_types:
            fs_types:
              - autofs
              - binfmt_misc
              - bpf
              - cgroup2
              - configfs
              - debugfs
              - devpts
              - devtmpfs
              - fusectl
              - hugetlbfs
              - iso9660
              - mqueue
              - nsfs
              - overlay
              - proc
              - procfs
              - pstore
              - rpc_pipefs
              - securityfs
              - selinuxfs
              - squashfs
              - sysfs
              - tracefs
            match_type: strict
        network:
{{- end }}

{{- define "otel-agent.applyClusterMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "otel-agent.clusterMetricsConfig" .Values | fromYaml) .config }}
{{- $_ := set $config.service.pipelines.metrics "receivers" (append $config.service.pipelines.metrics.receivers "k8s_cluster" | uniq)  }}
{{- $config | toYaml }}
{{- end }}

{{- define "otel-agent.clusterMetricsConfig" -}}
receivers:
  k8s_cluster:
    collection_interval: 10s
{{- end }}

{{- define "otel-agent.applyKubeletMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "otel-agent.kubeletMetricsConfig" .Values | fromYaml) .config }}
{{- $_ := set $config.service.pipelines.metrics "receivers" (append $config.service.pipelines.metrics.receivers "kubeletstats" | uniq)  }}
{{- $config | toYaml }}
{{- end }}

{{- define "otel-agent.kubeletMetricsConfig" -}}
receivers:
  kubeletstats:
    collection_interval: 20s
    auth_type: "serviceAccount"
    endpoint: "${env:K8S_NODE_NAME}:10250"
{{- end }}

{{- define "otel-agent.applyLogsCollectionConfig" -}}
{{- $config := mustMergeOverwrite (include "otel-agent.logsCollectionConfig" .Values | fromYaml) .config }}
{{- $_ := set $config.service.pipelines.logs "receivers" (append $config.service.pipelines.logs.receivers "filelog" | uniq)  }}
{{- if .Values.Values.presets.logsCollection.storeCheckpoints}}
{{- $_ := set $config.service "extensions" (append $config.service.extensions "file_storage" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "otel-agent.logsCollectionConfig" -}}
{{- if .Values.presets.logsCollection.storeCheckpoints }}
extensions:
  file_storage:
    directory: /var/lib/otelcol
{{- end }}
receivers:
  filelog:
    include: [ /var/log/pods/*/*/*.log ]
    {{- if .Values.presets.logsCollection.includeCollectorLogs }}
    exclude: []
    {{- else }}
    # Exclude collector container's logs. The file format is /var/log/pods/<namespace_name>_<pod_name>_<pod_uid>/<container_name>/<run_id>.log
    exclude: [ /var/log/pods/{{ .Release.Namespace }}_{{ include "otel-agent.fullname" . }}*_*/{{ include "otel-agent.lowercase_chartname" . }}/*.log ]
    {{- end }}
    start_at: end
    retry_on_failure:
        enabled: true
    {{- if .Values.presets.logsCollection.storeCheckpoints}}
    storage: file_storage
    {{- end }}
    include_file_path: true
    include_file_name: false
    operators:
      # Find out which format is used by kubernetes
      - type: router
        id: get-format
        routes:
          - output: parser-docker
            expr: 'body matches "^\\{"'
          - output: parser-crio
            expr: 'body matches "^[^ Z]+ "'
          - output: parser-containerd
            expr: 'body matches "^[^ Z]+Z"'
      # Parse CRI-O format
      - type: regex_parser
        id: parser-crio
        regex: '^(?P<time>[^ Z]+) (?P<stream>stdout|stderr) (?P<logtag>[^ ]*) ?(?P<log>.*)$'
        timestamp:
          parse_from: attributes.time
          layout_type: gotime
          layout: '2006-01-02T15:04:05.999999999Z07:00'
      - type: recombine
        id: crio-recombine
        output: extract_metadata_from_filepath
        combine_field: attributes.log
        source_identifier: attributes["log.file.path"]
        is_last_entry: "attributes.logtag == 'F'"
        combine_with: ""
        max_log_size: {{ $.Values.presets.logsCollection.maxRecombineLogSize }}
      # Parse CRI-Containerd format
      - type: regex_parser
        id: parser-containerd
        regex: '^(?P<time>[^ ^Z]+Z) (?P<stream>stdout|stderr) (?P<logtag>[^ ]*) ?(?P<log>.*)$'
        timestamp:
          parse_from: attributes.time
          layout: '%Y-%m-%dT%H:%M:%S.%LZ'
      - type: recombine
        id: containerd-recombine
        output: extract_metadata_from_filepath
        combine_field: attributes.log
        source_identifier: attributes["log.file.path"]
        is_last_entry: "attributes.logtag == 'F'"
        combine_with: ""
        max_log_size: {{ $.Values.presets.logsCollection.maxRecombineLogSize }}
      # Parse Docker format
      - type: json_parser
        id: parser-docker
        output: extract_metadata_from_filepath
        timestamp:
          parse_from: attributes.time
          layout: '%Y-%m-%dT%H:%M:%S.%LZ'
      # Extract metadata from file path
      - type: regex_parser
        id: extract_metadata_from_filepath
        regex: '^.*\/(?P<namespace>[^_]+)_(?P<pod_name>[^_]+)_(?P<uid>[a-f0-9\-]+)\/(?P<container_name>[^\._]+)\/(?P<restart_count>\d+)\.log$'
        parse_from: attributes["log.file.path"]
      # Rename attributes
      - type: move
        from: attributes.stream
        to: attributes["log.iostream"]
      - type: move
        from: attributes.container_name
        to: resource["k8s.container.name"]
      - type: move
        from: attributes.namespace
        to: resource["k8s.namespace.name"]
      - type: move
        from: attributes.pod_name
        to: resource["k8s.pod.name"]
      - type: move
        from: attributes.restart_count
        to: resource["k8s.container.restart_count"]
      - type: move
        from: attributes.uid
        to: resource["k8s.pod.uid"]
      # Clean up log body
      - type: move
        from: attributes.log
        to: body
{{- end }}

{{- define "otel-agent.applyKubernetesAttributesConfig" -}}
{{- $config := mustMergeOverwrite (include "otel-agent.kubernetesAttributesConfig" .Values | fromYaml) .config }}
{{- if and ($config.service.pipelines.logs) (not (has "k8sattributes" $config.service.pipelines.logs.processors)) }}
{{- $_ := set $config.service.pipelines.logs "processors" (prepend $config.service.pipelines.logs.processors "k8sattributes" | uniq)  }}
{{- end }}
{{- if and ($config.service.pipelines.metrics) (not (has "k8sattributes" $config.service.pipelines.metrics.processors)) }}
{{- $_ := set $config.service.pipelines.metrics "processors" (prepend $config.service.pipelines.metrics.processors "k8sattributes" | uniq)  }}
{{- end }}
{{- if and ($config.service.pipelines.traces) (not (has "k8sattributes" $config.service.pipelines.traces.processors)) }}
{{- $_ := set $config.service.pipelines.traces "processors" (prepend $config.service.pipelines.traces.processors "k8sattributes" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "otel-agent.kubernetesAttributesConfig" -}}
processors:
  k8sattributes:
  {{- if eq .Values.mode "daemonset" }}
    filter:
      node_from_env_var: K8S_NODE_NAME
  {{- end }}
    passthrough: false
    pod_association:
    - sources:
      - from: resource_attribute
        name: k8s.pod.ip
    - sources:
      - from: resource_attribute
        name: k8s.pod.uid
    - sources:
      - from: connection
    extract:
      metadata:
        - "k8s.namespace.name"
        - "k8s.deployment.name"
        - "k8s.statefulset.name"
        - "k8s.daemonset.name"
        - "k8s.cronjob.name"
        - "k8s.job.name"
        - "k8s.node.name"
        - "k8s.pod.name"
        - "k8s.pod.uid"
        - "k8s.pod.start_time"
      {{- if .Values.presets.kubernetesAttributes.extractAllPodLabels }}
      labels:
        - tag_name: $$1
          key_regex: (.*)
          from: pod
      {{- end }}
      {{- if .Values.presets.kubernetesAttributes.extractAllPodAnnotations }}
      annotations:
        - tag_name: $$1
          key_regex: (.*)
          from: pod
      {{- end }}
{{- end }}

{{/* Build the list of port for service */}}
{{- define "otel-agent.servicePortsConfig" -}}
{{- $ports := deepCopy .Values.ports }}
{{- range $key, $port := $ports }}
{{- if $port.enabled }}
- name: {{ $key }}
  port: {{ $port.servicePort }}
  targetPort: {{ $port.containerPort }}
  protocol: {{ $port.protocol }}
  {{- if $port.appProtocol }}
  appProtocol: {{ $port.appProtocol }}
  {{- end }}
{{- if $port.nodePort }}
  nodePort: {{ $port.nodePort }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* Build the list of port for pod */}}
{{- define "otel-agent.podPortsConfig" -}}
{{- $ports := deepCopy .Values.ports }}
{{- range $key, $port := $ports }}
{{- if $port.enabled }}
- name: {{ $key }}
  containerPort: {{ $port.containerPort }}
  protocol: {{ $port.protocol }}
  {{- if and $.isAgent $port.hostPort }}
  hostPort: {{ $port.hostPort }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "otel-agent.applyKubernetesEventsConfig" -}}
{{- $config := mustMergeOverwrite (include "otel-agent.kubernetesEventsConfig" .Values | fromYaml) .config }}
{{- $_ := set $config.service.pipelines.logs "receivers" (append $config.service.pipelines.logs.receivers "k8sobjects" | uniq)  }}
{{- $config | toYaml }}
{{- end }}

{{- define "otel-agent.kubernetesEventsConfig" -}}
receivers:
  k8sobjects:
    objects:
      - name: events
        mode: "watch"
        group: "events.k8s.io"
        exclude_watch_type:
          - "DELETED"
{{- end }}
