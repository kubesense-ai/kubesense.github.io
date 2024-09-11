{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "vmNodeaffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "vmNodeAffinityRequiredDuringScheduling" . }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "vmNodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "vmNodeAffinityRequiredDuringScheduling" }}
    {{- if or .Values.nodeAffinityLabelSelector .Values.global.nodeAffinityLabelSelector }}
      nodeSelectorTerms:
      {{- range $matchExpressionsIndex, $matchExpressionsItem := .Values.nodeAffinityLabelSelector }}
        - matchExpressions:
        {{- range $Index, $item := $matchExpressionsItem.matchExpressions }}
          - key: {{ $item.key }}
            operator: {{ $item.operator }}
            {{- if $item.values }}
            values:
            {{- $vals := split "," $item.values }}
            {{- range $i, $v := $vals }}
            - {{ $v | quote }}
            {{- end }}
            {{- end }}
          {{- end }}
      {{- end }}
      {{- range $matchExpressionsIndex, $matchExpressionsItem := .Values.global.nodeAffinityLabelSelector }}
        - matchExpressions:
        {{- range $Index, $item := $matchExpressionsItem.matchExpressions }}
          - key: {{ $item.key }}
            operator: {{ $item.operator }}
            {{- if $item.values }}
            values:
            {{- $vals := split "," $item.values }}
            {{- range $i, $v := $vals }}
            - {{ $v | quote }}
            {{- end }}
            {{- end }}
          {{- end }}
      {{- end }}
    {{- end }}
{{- end }}

{{- define "vmNodeAffinityPreferredDuringScheduling" }}
    {{- range $weightIndex, $weightItem := .Values.nodeAffinityTermLabelSelector }}
    - weight: {{ $weightItem.weight }}
      preference:
        matchExpressions:
      {{- range $Index, $item := $weightItem.matchExpressions }}
        - key: {{ $item.key }}
          operator: {{ $item.operator }}
          {{- if $item.values }}
          values:
          {{- $vals := split "," $item.values }}
          {{- range $i, $v := $vals }}
          - {{ $v | quote }}
          {{- end }}
          {{- end }}
      {{- end }}
    {{- end }}
    {{- range $weightIndex, $weightItem := .Values.global.nodeAffinityTermLabelSelector }}
    - weight: {{ $weightItem.weight }}
      preference:
        matchExpressions:
      {{- range $Index, $item := $weightItem.matchExpressions }}
        - key: {{ $item.key }}
          operator: {{ $item.operator }}
          {{- if $item.values }}
          values:
          {{- $vals := split "," $item.values }}
          {{- range $i, $v := $vals }}
          - {{ $v | quote }}
          {{- end }}
          {{- end }}
      {{- end }}
    {{- end }}
{{- end }}


{{- define "vmPodAffinity" }}
{{- if or .Values.podAffinityLabelSelector .Values.podAffinityTermLabelSelector}}
  podAffinity:
    {{- if .Values.podAffinityLabelSelector }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "vmPodAffinityRequiredDuringScheduling" . }}
    {{- end }}
    {{- if or .Values.podAffinityTermLabelSelector}}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "vmPodAffinityPreferredDuringScheduling" . }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "vmPodAffinityRequiredDuringScheduling" }}
    {{- range $labelSelector, $labelSelectorItem := .Values.podAffinityLabelSelector }}
    - labelSelector:
        matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
        - key: {{ $item.key }}
          operator: {{ $item.operator }}
          {{- if $item.values }}
          values:
          {{- $vals := split "," $item.values }}
          {{- range $i, $v := $vals }}
          - {{ $v | quote }}
          {{- end }}
          {{- end }}
        {{- end }}
      topologyKey: {{ $labelSelectorItem.topologyKey }}
    {{- end }}
    {{- range $labelSelector, $labelSelectorItem := .Values.global.podAffinityLabelSelector }}
    - labelSelector:
        matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
        - key: {{ $item.key }}
          operator: {{ $item.operator }}
          {{- if $item.values }}
          values:
          {{- $vals := split "," $item.values }}
          {{- range $i, $v := $vals }}
          - {{ $v | quote }}
          {{- end }}
          {{- end }}
        {{- end }}
      topologyKey: {{ $labelSelectorItem.topologyKey }}
    {{- end }}
{{- end }}

{{- define "vmPodAffinityPreferredDuringScheduling" }}
    {{- range $labelSelector, $labelSelectorItem := .Values.podAffinityTermLabelSelector }}
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
          - key: {{ $item.key }}
            operator: {{ $item.operator }}
            {{- if $item.values }}
            values:
            {{- $vals := split "," $item.values }}
            {{- range $i, $v := $vals }}
            - {{ $v | quote }}
            {{- end }}
            {{- end }}
        {{- end }}
        topologyKey: {{ $labelSelectorItem.topologyKey }}
      weight:  {{ $labelSelectorItem.weight }}
    {{- end }}
    {{- range $labelSelector, $labelSelectorItem := .Values.global.podAffinityTermLabelSelector }}
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
          - key: {{ $item.key }}
            operator: {{ $item.operator }}
            {{- if $item.values }}
            values:
            {{- $vals := split "," $item.values }}
            {{- range $i, $v := $vals }}
            - {{ $v | quote }}
            {{- end }}
            {{- end }}
        {{- end }}
        topologyKey: {{ $labelSelectorItem.topologyKey }}
      weight:  {{ $labelSelectorItem.weight }}
    {{- end }}
{{- end }}

{{- define "vmPodAntiAffinity" }}
{{- if or .Values.podAntiAffinityLabelSelector .Values.podAntiAffinityTermLabelSelector}}
  podAntiAffinity:
    {{- if .Values.podAntiAffinityLabelSelector }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "vmPodAntiAffinityRequiredDuringScheduling" . }}
    {{- end }}
    {{- if or .Values.podAntiAffinityTermLabelSelector}}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "vmPodAntiAffinityPreferredDuringScheduling" . }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "vmPodAntiAffinityRequiredDuringScheduling" }}
    {{- range $labelSelectorIndex, $labelSelectorItem := .Values.podAntiAffinityLabelSelector }}
    - labelSelector:
        matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
        - key: {{ $item.key }}
          operator: {{ $item.operator }}
          {{- if $item.values }}
          values:
          {{- $vals := split "," $item.values }}
          {{- range $i, $v := $vals }}
          - {{ $v | quote }}
          {{- end }}
          {{- end }}
        {{- end }}
      topologyKey: {{ $labelSelectorItem.topologyKey }}
    {{- end }}
    {{- range $labelSelectorIndex, $labelSelectorItem := .Values.global.podAntiAffinityLabelSelector }}
    - labelSelector:
        matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
        - key: {{ $item.key }}
          operator: {{ $item.operator }}
          {{- if $item.values }}
          values:
          {{- $vals := split "," $item.values }}
          {{- range $i, $v := $vals }}
          - {{ $v | quote }}
          {{- end }}
          {{- end }}
        {{- end }}
      topologyKey: {{ $labelSelectorItem.topologyKey }}
    {{- end }}
{{- end }}

{{- define "vmPodAntiAffinityPreferredDuringScheduling" }}
    {{- range $labelSelectorIndex, $labelSelectorItem := .Values.podAntiAffinityTermLabelSelector }}
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
          - key: {{ $item.key }}
            operator: {{ $item.operator }}
            {{- if $item.values }}
            values:
            {{- $vals := split "," $item.values }}
            {{- range $i, $v := $vals }}
            - {{ $v | quote }}
            {{- end }}
            {{- end }}
        {{- end }}
        topologyKey: {{ $labelSelectorItem.topologyKey }}
      weight: {{ $labelSelectorItem.weight }}
    {{- end }}
    {{- range $labelSelectorIndex, $labelSelectorItem := .Values.global.podAntiAffinityTermLabelSelector }}
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
      {{- range $index, $item := $labelSelectorItem.labelSelector }}
          - key: {{ $item.key }}
            operator: {{ $item.operator }}
            {{- if $item.values }}
            values:
            {{- $vals := split "," $item.values }}
            {{- range $i, $v := $vals }}
            - {{ $v | quote }}
            {{- end }}
            {{- end }}
        {{- end }}
        topologyKey: {{ $labelSelectorItem.topologyKey }}
      weight: {{ $labelSelectorItem.weight }}
    {{- end }}
{{- end }}