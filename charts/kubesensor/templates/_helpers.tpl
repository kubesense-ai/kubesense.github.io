{{/*
Expand the name of the chart.
*/}}
{{- define "kubesensor.name" -}}
{{- default "kubesensor" -}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "logsensor.name" -}}
{{- default "logsensor" -}}
{{- end }}

{{- define "kubesensor.fullname" -}}
{{- default "kubesense-kubesensor" -}}
{{- end }}

{{- define "logsensor.fullname" -}}
{{- default "kubesense-logsensor" -}}
{{- end }}

{{- define "kubesensor.cluterrolename" -}}
{{- printf "%s-%s" .Release.Name (include "kubesensor.name" .) -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubesensor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubesensor.labels" -}}
helm.sh/chart: {{ include "kubesensor.chart" . }}
{{ include "kubesensor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kubesensor.selectorLabels" -}}
app: kubesense
component: kubesensor
app.kubernetes.io/name: {{ include "kubesensor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
vector.dev/exclude: "true"
{{- end }}

{{/*
Common labels
*/}}
{{- define "logsensor.labels" -}}
helm.sh/chart: {{ include "kubesensor.chart" . }}
{{ include "logsensor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "logsensor.selectorLabels" -}}
app: kubesense
component: logsensor
app.kubernetes.io/name: {{ include "logsensor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
vector.dev/exclude: "true"
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kubesensor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kubesensor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
