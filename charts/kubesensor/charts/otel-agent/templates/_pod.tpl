{{- define "otel-agent.pod" -}}
{{ if $.Values.global.image.pullSecrets }}
imagePullSecrets:
  - name: {{ $.Values.global.image.pullSecrets }}
{{ end }}
serviceAccountName: {{ include "otel-agent.serviceAccountName" . }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- with .Values.hostAliases }}
hostAliases:
  {{- toYaml . | nindent 2 }}
{{- end }}
containers:
  - name: {{ include "otel-agent.lowercase_chartname" . }}
    securityContext:
      {{- if and (not (.Values.securityContext)) (.Values.presets.logsCollection.storeCheckpoints) }}
      runAsUser: 0
      runAsGroup: 0
      {{- else -}}
      {{- toYaml .Values.securityContext | nindent 6 }}
      {{- end }}
    {{- if .Values.image.digest }}
    image: "{{ ternary "" (print (.Values.global).imageRegistry "/") (empty (.Values.global).imageRegistry) }}{{ .Values.image.repository }}@{{ .Values.image.digest }}"
    {{- else }}
    image: "{{ ternary "" (print (.Values.global).imageRegistry "/") (empty (.Values.global).imageRegistry) }}{{ tpl .Values.image.repository . }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    {{- end }}
    imagePullPolicy: "{{ tpl .Values.image.pullPolicy . }}"
    {{- $ports := include "otel-agent.podPortsConfig" . }}
    {{- if $ports }}
    ports:
      {{- $ports | nindent 6}}
    {{- end }}
    {{- with .Values.readinessProbe }}
    readinessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.livenessProbe }}
    livenessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    env:
      - name: MY_POD_IP
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: status.podIP
      {{- if or .Values.presets.kubeletMetrics.enabled (and .Values.presets.kubernetesAttributes.enabled (eq .Values.mode "daemonset")) }}
      - name: K8S_NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      {{- end }}
      {{- if and (.Values.useGOMEMLIMIT) ((((.Values.resources).limits).memory))  }}
      - name: GOMEMLIMIT
        value: {{ include "otel-agent.gomemlimit" .Values.resources.limits.memory | quote }}
      {{- end }}
      {{- with .Values.extraEnvs }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
    {{- with .Values.extraEnvsFrom }}
    envFrom:
    {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- if .Values.lifecycleHooks }}
    lifecycle:
      {{- toYaml .Values.lifecycleHooks | nindent 6 }}
    {{- end }}
    {{- with .Values.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    volumeMounts:
      {{- if .Values.configMap.create }}
      - name: {{ include "otel-agent.lowercase_chartname" . }}-configmap
        mountPath: /etc/otel/config.yaml
        subPath: config.yaml
      {{- end }}
      {{- if .Values.presets.logsCollection.enabled }}
      - name: varlogpods
        mountPath: /var/log/pods
        readOnly: true
      - name: varlibdockercontainers
        mountPath: /var/lib/docker/containers
        readOnly: true
      {{- if .Values.presets.logsCollection.storeCheckpoints}}
      - name: varlibotelcol
        mountPath: /var/lib/otelcol
      {{- end }}
      {{- end }}
      {{- if .Values.presets.hostMetrics.enabled }}
      - name: hostfs
        mountPath: /hostfs
        readOnly: true
        mountPropagation: HostToContainer
      {{- end }}
      {{- if .Values.extraVolumeMounts }}
      {{- toYaml .Values.extraVolumeMounts | nindent 6 }}
      {{- end }}
{{- with .Values.extraContainers }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- if .Values.initContainers }}
initContainers:
  {{- tpl (toYaml .Values.initContainers) . | nindent 2 }}
{{- end }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName | quote }}
{{- end }}
volumes:
  {{- if .Values.configMap.create }}
  - name: {{ include "otel-agent.lowercase_chartname" . }}-configmap
    configMap:
      name: {{ include "otel-agent.fullname" . }}{{ .configmapSuffix }}
      items:
        - key: config.yaml
          path: config.yaml
  {{- end }}
  {{- if .Values.presets.logsCollection.enabled }}
  - name: varlogpods
    hostPath:
      path: /var/log/pods
  {{- if .Values.presets.logsCollection.storeCheckpoints}}
  - name: varlibotelcol
    hostPath:
      path: /var/lib/otelcol
      type: DirectoryOrCreate
  {{- end }}
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers
  {{- end }}
  {{- if .Values.presets.hostMetrics.enabled }}
  - name: hostfs
    hostPath:
      path: /
  {{- end }}
  {{- if .Values.extraVolumes }}
  {{- toYaml .Values.extraVolumes | nindent 2 }}
  {{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}