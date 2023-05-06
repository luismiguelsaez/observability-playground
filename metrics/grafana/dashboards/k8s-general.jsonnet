
local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local gauge = grafana.gaugePanel;
local graph = grafana.graphPanel;
local heatmap = grafana.heatmapPanel;
local bargauge = grafana.barGaugePanel;
local prometheus = grafana.prometheus;

local serviceName = 'languagetool';

local jvm_memory = bargauge.new(
                      'JVM memory distribution',
                      datasource='Prometheus',
                      unit='bytes',
                    )
                    .addTarget(
                      prometheus.target(
                        expr='avg by (__name__) ({__name__=~"java_lang_.*Usage_used",__name__!~".*Peak.*",pod=~"%s-.*"})' % [serviceName],
                        legendFormat='{{ __name__ }}'
                      )
                    )
                    + {
                        options+: {
                          orientation: "horizontal",
                          displayMode: "lcd",
                        }
                      };

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
                        legend_values=true,
                        formatY1='bytes',
                        formatY2='percentunit',
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_HeapMemoryUsage_used{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Used',
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_HeapMemoryUsage_committed{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Committed'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_HeapMemoryUsage_max{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Max'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(
                                  java_lang_Memory_HeapMemoryUsage_used{pod=~"%s-.*"}
                                  /
                                  java_lang_Memory_HeapMemoryUsage_max{pod=~"%s-.*"}
                                )' % [serviceName, serviceName],
                          legendFormat='Usage %',
                        )
                      )
                      .addSeriesOverride({})
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "custom.drawStyle",
                              "value": "bars"
                            },
                          ]
                      )
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "custom.fillOpacity",
                              "value": 80
                            },
                          ]
                      )
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "color",
                              "value": {
                                "fixedColor": "#6d1f62",
                                "mode": "fixed"
                              }
                            },
                          ]
                      )
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "custom.axisPlacement",
                              "value": "right"
                            },
                          ]
                      ) 
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "unit",
                              "value": "percentunit"
                            },
                          ]
                      )
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "decimals",
                              "value": 1
                            },
                          ]
                      ) 
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "min",
                              "value": 0
                            },
                          ]
                      ) 
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "max",
                              "value": 1
                            },
                          ]
                      )
                      .addOverride(
                          matcher={ id: "byName", options: "Usage %" },
                          properties=[
                            {
                              "id": "custom.lineWidth",
                              "value": 0
                            },
                          ]
                      )
                      + { type: "timeseries",
                          fieldConfig+: { defaults+: { unit: "bytes" } },
                          options+: {
                            legend+: {
                              displayMode: "table",
                              showLegend: true,
                              placement: "bottom",
                              calcs: [
                                "mean",
                                "lastNotNull",
                                "max",
                                "min"
                              ]
                            }
                          }
                        };

local jvm_memory_area_non_heap = graph.new(
                        'JVM Memory Area (Non-Heap)',
                        datasource='Prometheus',
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_NonHeapMemoryUsage_used{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Used'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Memory_NonHeapMemoryUsage_committed{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Committed'
                        )
                      )
                      + { type: "timeseries",
                          fieldConfig+: { defaults+: { unit: "bytes", custom+: { fillOpacity: 10 } } },
                          options+: {
                            legend+: {
                              displayMode: "table",
                              showLegend: true,
                              placement: "bottom",
                              calcs: [
                                "mean",
                                "lastNotNull",
                                "max",
                                "min"
                              ]
                            }
                          }
                        };

local jvm_threads_used = graph.new(
                        'JVM Threads used',
                        datasource='Prometheus',
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Threading_ThreadCount{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Current'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Threading_DaemonThreadCount{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Daemon'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_Threading_PeakThreadCount{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Peak'
                        )
                      )
                      + { type: "timeseries",
                            fieldConfig+: { defaults+: { custom+: { fillOpacity: 10 } } },
                            options+: {
                              legend+: {
                                displayMode: "table",
                                showLegend: true,
                                placement: "bottom",
                                calcs: [
                                  "mean",
                                  "lastNotNull",
                                  "max",
                                  "min"
                                ]
                              }
                            }
                          };

local jvm_class_loading = graph.new(
                        'JVM Class Loading',
                        datasource='Prometheus',
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_ClassLoading_LoadedClassCount{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Loaded'
                        )
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(java_lang_ClassLoading_TotalLoadedClassCount{pod=~"%s-.*"})' % [serviceName],
                          legendFormat='Total'
                        )
                      )
                      + { type: "timeseries",
                            fieldConfig+: { defaults+: { unit: "bytes", custom+: { fillOpacity: 10 } } },
                            options+: {
                              legend+: {
                                displayMode: "table",
                                showLegend: true,
                                placement: "bottom",
                                calcs: [
                                  "mean",
                                  "lastNotNull",
                                  "max",
                                  "min"
                                ]
                              }
                            }
                          };

local jvm_gc_time = graph.new(
                        'JVM GC Time [3m]',
                        datasource='Prometheus',
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(rate(java_lang_G1_Young_Generation_LastGcInfo_duration{pod=~"%s-.*"}[3m]))' % [serviceName],
                          legendFormat='Time'
                        )
                      )
                      + { type: "timeseries",
                            fieldConfig+: { defaults+: { unit: "s", custom+: { fillOpacity: 10 } } },
                            options+: {
                              legend+: {
                                displayMode: "table",
                                showLegend: true,
                                placement: "bottom",
                                calcs: [
                                  "mean",
                                  "lastNotNull",
                                  "max",
                                  "min"
                                ]
                              }
                            }
                          };

local jvm_gc_count = graph.new(
                        'JVM GC Count Increase [3m]',
                        datasource='Prometheus',
                      )
                      .addTarget(
                        prometheus.target(
                          expr='avg(increase(java_lang_G1_Young_Generation_LastGcInfo_duration{pod=~"%s-.*"}[3m]))' % [serviceName],
                          legendFormat='Count'
                        )
                      )
                      + { type: "timeseries",
                            fieldConfig+: { defaults+: { custom+: { fillOpacity: 10 } } },
                            options+: {
                              legend+: {
                                displayMode: "table",
                                showLegend: true,
                                placement: "bottom",
                                calcs: [
                                  "mean",
                                  "lastNotNull",
                                  "max",
                                  "min"
                                ]
                              }
                            }
                          };

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
.addPanel( jvm_threads_used, gridPos={ x: 0, y: 0, w: 6, h: 8, } )
.addPanel( jvm_class_loading, gridPos={ x: 6, y: 0, w: 6, h: 8, } )
.addPanel( jvm_gc_time, gridPos={ x: 12, y: 0, w: 6, h: 8, } )
.addPanel( jvm_gc_count, gridPos={ x: 18, y: 0, w: 6, h: 8, } )
