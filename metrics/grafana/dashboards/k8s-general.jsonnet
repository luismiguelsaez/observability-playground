
local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local gauge = grafana.gaugePanel;
local graph = grafana.graphPanel;
local heatmap = grafana.heatmapPanel;
local bargauge = grafana.barGaugePanel;
local prometheus = grafana.prometheus;

local jvm_memory = bargauge.new(
                      'JVM memory distribution',
                      datasource='Prometheus',
                      unit='bytes',
                    )
                    .addTarget(
                      prometheus.target(
                        expr='avg by (__name__) ({__name__=~"java_lang_.*Usage_used",__name__!~".*Peak.*",pod=~"languagetool-.*"})',
                        legendFormat='{{ __name__ }}'
                      )
                    ) + { options+: {
                      orientation: "horizontal",
                      displayMode: "lcd",
                    }};

local node_cpu_usage = graph.new(
                        'CPU usage',
                        datasource='Prometheus'
                      )
                      .addTarget(
                        prometheus.target(
                          'sum by (name,role) (rate(node_cpu_seconds_total{env="$env",mode!="idle",name=~"$node"}[5m]))
                          /
                          count by (name,role) (sum by (name,role,cpu) (node_cpu_seconds_total{env="$env",name=~"$node"})) * 100',
                          legendFormat='{{ role }}',
                        )
                      );

local jvm_memory_area_heap = graph.new(
                        'JVM Memory Area (Heap)',
                        datasource='Prometheus',
                        legend_alignAsTable=true,
                        legend_avg=true,
                        legend_max=true,
                        legend_min=true,
                        legend_values=true
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_HeapMemoryUsage_used{pod=~"languagetool-.*"})',
                          legendFormat='Used',
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_HeapMemoryUsage_committed{pod=~"languagetool-.*"})',
                          legendFormat='Committed'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_HeapMemoryUsage_max{pod=~"languagetool-.*"})',
                          legendFormat='Max'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(
                                  java_lang_Memory_HeapMemoryUsage_used{pod=~"languagetool-.*"}
                                  /
                                  java_lang_Memory_HeapMemoryUsage_max{pod=~"languagetool-.*"}
                                )',
                          legendFormat='Used %'
                        )
                      );

local jvm_memory_area_non_heap = graph.new(
                        'JVM Memory Area (Non-Heap)',
                        datasource='Prometheus',
                        legend_alignAsTable=true,
                        legend_avg=true,
                        legend_max=true,
                        legend_min=true,
                        legend_values=true
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_NonHeapMemoryUsage_used{pod=~"languagetool-.*"})',
                          legendFormat='Used'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_NonHeapMemoryUsage_committed{pod=~"languagetool-.*"})',
                          legendFormat='Committed'
                        )
                      );

dashboard.new(
  title = "K8s node resources",
  editable=true,
)
.addTemplate(
  grafana.template.datasource(
    'PROM_DEFAULT','prometheus','Prometheus'
  )
)
.addTemplate(
  grafana.template.new(
    'env',
    '$PROM_DEFAULT',
    'label_values(kube_node_info, env)'
  )
)
.addTemplate(
  grafana.template.new(
    'node',
    '$PROM_DEFAULT',
    'label_values(kube_node_info{env="$env"}, exported_node)',
    multi=true,
    includeAll=true,
  )
)
.addPanel( node_cpu_usage, gridPos={ x: 0, y: 0, w: 24, h: 8, } )
.addPanel( jvm_memory, gridPos={ x: 0, y: 0, w: 24, h: 8, } )
.addPanel( jvm_memory_area_heap, gridPos={ x: 0, y: 0, w: 12, h: 8, } )
.addPanel( jvm_memory_area_non_heap, gridPos={ x: 12, y: 0, w: 12, h: 8, } )
