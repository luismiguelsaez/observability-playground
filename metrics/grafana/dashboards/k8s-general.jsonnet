
local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local gauge = grafana.gaugePanel;
local graph = grafana.graphPanel;
local heatmap = grafana.heatmapPanel;
local prometheus = grafana.prometheus;


dashboard.new(
  title = "K8s nodes"
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
.addPanel(
  graph.new(
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
  ), gridPos={
    x: 0,
    y: 0,
    w: 24,
    h: 8,
  }
)
