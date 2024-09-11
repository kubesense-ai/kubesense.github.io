{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "serverNodeaffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "serverNodeAffinityRequiredDuringScheduling" . }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "serverNodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "serverNodeAffinityRequiredDuringScheduling" }}
    {{- if or .Values.kubecol.nodeAffinityLabelSelector .Values.global.nodeAffinityLabelSelector }}
      nodeSelectorTerms:
      {{- range $matchExpressionsIndex, $matchExpressionsItem := .Values.kubecol.nodeAffinityLabelSelector }}
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
    {{-  if eq (len .Values.kubecol.nodeAffinityLabelSelector) 0 }}  
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
{{- end }}

{{- define "serverNodeAffinityPreferredDuringScheduling" }}
    {{- range $weightIndex, $weightItem := .Values.kubecol.nodeAffinityTermLabelSelector }}
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
    {{- if gt (len .Values.kubecol.nodeAffinityTermLabelSelector) 0 }}
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
{{- end }}


{{- define "serverPodAffinity" }}
{{- if or .Values.kubecol.podAffinityLabelSelector .Values.kubecol.podAffinityTermLabelSelector}}
  podAffinity:
    {{- if .Values.kubecol.podAffinityLabelSelector }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "serverPodAffinityRequiredDuringScheduling" . }}
    {{- end }}
    {{- if or .Values.kubecol.podAffinityTermLabelSelector}}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "serverPodAffinityPreferredDuringScheduling" . }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "serverPodAffinityRequiredDuringScheduling" }}
    {{- range $labelSelector, $labelSelectorItem := .Values.kubecol.podAffinityLabelSelector }}
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

{{- define "serverPodAffinityPreferredDuringScheduling" }}
    {{- range $labelSelector, $labelSelectorItem := .Values.kubecol.podAffinityTermLabelSelector }}
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

{{- define "serverPodAntiAffinity" }}
{{- if or .Values.kubecol.podAntiAffinityLabelSelector .Values.kubecol.podAntiAffinityTermLabelSelector}}
  podAntiAffinity:
    {{- if .Values.kubecol.podAntiAffinityLabelSelector }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "serverPodAntiAffinityRequiredDuringScheduling" . }}
    {{- end }}
    {{- if or .Values.kubecol.podAntiAffinityTermLabelSelector}}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "serverPodAntiAffinityPreferredDuringScheduling" . }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "serverPodAntiAffinityRequiredDuringScheduling" }}
    {{- range $labelSelectorIndex, $labelSelectorItem := .Values.kubecol.podAntiAffinityLabelSelector }}
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

{{- define "serverPodAntiAffinityPreferredDuringScheduling" }}
    {{- range $labelSelectorIndex, $labelSelectorItem := .Values.kubecol.podAntiAffinityTermLabelSelector }}
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