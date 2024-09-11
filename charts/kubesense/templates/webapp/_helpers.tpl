{{/*
Expand the name of the chart.
*/}}
{{- define "webapp.name" -}}
{{- default "webapp" -}}
{{- end }}

{{- define "webapp.fullname" -}}
{{- printf "%s-webapp" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "webapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "webapp.labels" -}}
# helm.sh/chart: {{ include "webapp.chart" . }}
{{ include "webapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "webapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "webapp.serviceAccountName" -}}
{{- if .Values.webapp.serviceAccount.create }}
{{- default (include "webapp.fullname" .) .Values.webapp.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.webapp.serviceAccount.name }}
{{- end }}
{{- end }}
