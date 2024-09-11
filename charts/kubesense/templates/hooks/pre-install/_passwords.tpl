{{- define "display" -}}
{{- range $k, $v := . -}}
- key: {{ $k }}
  value: {{ $v }}
{{ end -}}
{{ end -}}

{{- define "passwords.namespace" -}}
{{- .Release.Namespace }}
{{- end }}

{{- define "passwords.secret" }}
{{- $secret := (lookup "v1" "Secret" (include "passwords.namespace" .) "kubesense-secret" ) }}
{{- if $secret }}
{{- index $secret "data" }}
{{- else }}
{{- $randomPasswords := dict "REDIS_PASSWORD" (randAlphaNum 40 | b64enc) "MYSQL_PASSWORD" (randAlphaNum 40 | b64enc) "CLICKHOUSE_PASSWORD" (randAlphaNum 20 | b64enc) }} 
{{- $randomPasswords }}
{{- end -}}
{{- end -}}

{{- define "passwords.isSecretPresent" }}
{{- $secret := (lookup "v1" "Secret" (include "passwords.namespace" .) "kubesense-secret" ) }}
{{- if $secret }}
{{ printf "true" | trimSuffix "-" }}
{{ else }}
{{ printf "false" | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "passwords.redis-password" }}
{{- $secret := (lookup "v1" "Secret" (include "passwords.namespace" .) "kubesense-secret" ) }}
{{- if $secret }}
{{- $password := (index $secret "data" "REDIS_PASSWORD" | b64dec) }}
{{- set $.Values.global.redis "password" $password -}}
{{- $.Values.global.redis.password }}
{{- else if .Values.global.redis.password }}
{{- .Values.global.redis.password }}
{{- else }}
{{- $randomPassword := (randAlphaNum 40) }}
{{- set $.Values.global.redis "password" $randomPassword -}}
{{- $.Values.global.redis.password  }}
{{- end -}}
{{- end -}}

{{- define "passwords.mysql-password" }}
{{- $secret := (lookup "v1" "Secret" (include "passwords.namespace" .) "kubesense-secret" ) }}
{{- if $secret }}
{{- $password := (index $secret "data" "MYSQL_PASSWORD" | b64dec) }}
{{- set $.Values.global.mysql "password" $password -}}
{{- $.Values.global.mysql.password  }}
{{- else if .Values.global.mysql.password }}
{{- .Values.global.mysql.password }}
{{- else }}
{{- $randomPassword := (randAlphaNum 40) }}
{{- set $.Values.global.mysql "password" $randomPassword -}}
{{- $.Values.global.mysql.password  }}
{{- end -}}
{{- end -}}

{{- define "passwords.clickhouse-password" }}
{{- $secret := (lookup "v1" "Secret" (include "passwords.namespace" .) "kubesense-secret" ) }}
{{- if $secret }}
{{- $password := (index $secret "data" "CLICKHOUSE_PASSWORD" | b64dec) }}
{{- set $.Values.global.clickhouse "password" $password -}}
{{- $.Values.global.clickhouse.password   }}
{{- else if .Values.global.clickhouse.password }}
{{- .Values.global.clickhouse.password }}
{{- else }}
{{- $randomPassword := (randAlphaNum 40) }}
{{- set $.Values.global.clickhouse "password" $randomPassword -}}
{{- $.Values.global.clickhouse.password   }}
{{- end -}}
{{- end -}}
