{{/*
Expand the name of the chart.
*/}}
{{- define "api.name" -}}
{{- default "api" -}}
{{- end }}

{{- define "api.fullname" -}}
{{- printf "%s-api" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "api.labels" -}}
# helm.sh/chart: {{ include "api.chart" . }}
{{ include "api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "api.serviceAccountName" -}}
{{- if .Values.api.serviceAccount.create }}
{{- default (include "api.fullname" .) .Values.api.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.api.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "api.initContainers" -}}
{{ $root := . }}
{{ with .Values.global.initContainers }}
{{- range $index, $item := . -}}
- name: {{$item.name}}
  image: {{ tpl $item.image $root }}
  imagePullPolicy: {{ tpl $item.imagePullPolicy $root }}
  command: {{ toYaml $item.command | nindent 4 }}
  resources: {{ toYaml $item.resources | nindent 4 }}
  env: {{ toYaml $item.env | nindent 4 }}
{{ end }}
{{ end }}
{{ end }}
