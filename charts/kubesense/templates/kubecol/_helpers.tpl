{{- define "kubecol.name" -}}
{{- default "kubecol" -}}
{{- end }}

{{- define "kubecol.fullname" -}}
{{- printf "%s-kubecol" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubecol.chart" -}}
{{- $kubesenseChartName := "kubesense" }}
{{- printf "%s-%s" $kubesenseChartName .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kubecol.selectorLabels" -}}
app: kubecol
app.kubernetes.io/name: {{ include "kubecol.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubecol.labels" -}}
helm.sh/chart: {{ include "kubecol.chart" . }}
{{ include "kubecol.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Return the appropriate apiVersion for HPA autoscaling APIs.
*/}}
{{- define "kubecol.autoscaling.apiVersion" -}}
{{- if or (.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler") (semverCompare ">=1.23" .Capabilities.KubeVersion.Version) -}}
"autoscaling/v2"
{{- else -}}
"autoscaling/v2beta2"
{{- end -}}
{{- end -}}

{{- define "kubecol.initContainers" -}}
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
