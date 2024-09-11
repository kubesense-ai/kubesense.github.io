{{/*
Expand the name of the chart.
*/}}
{{- define "ssl-cert.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ssl-cert.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate certificates for ssl-cert api server 
*/}}
{{- define "ssl-cert.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "ssl-cert.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "ssl-cert.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "ssl-cert-ca" 365 -}}
{{- $cert := genSelfSignedCert ( include "ssl-cert.name" . ) nil nil 365 -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

