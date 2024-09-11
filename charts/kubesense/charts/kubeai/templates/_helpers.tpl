{{/*
Expand the name of the chart.
*/}}
{{- define "kubeai.name" -}}
{{- default "kubeai" -}}
{{- end }}

{{- define "kubeai.fullname" -}}
{{- default "kubesense-kubeai" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubeai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubeai.labels" -}}
helm.sh/chart: {{ include "kubeai.chart" . }}
{{ include "kubeai.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kubeai.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubeai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kubeai.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kubeai.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
