local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';

{
  new :: function (
    name,
    description='',
    default_unit='',
    datasource='',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_max=true,
    legend_min=true,
    legend_values=true,
    formatY1='bytes',
    formatY2='percentunit',
  )
  grafana.graphPanel.new(
    name,
    description=description,
    datasource=datasource,
    legend_alignAsTable=legend_alignAsTable,
    legend_avg=legend_avg,
    legend_max=legend_max,
    legend_min=legend_min,
    legend_values=legend_values,
    formatY1=default_unit,
    formatY2=formatY1,
  )
  + { type: "timeseries",
      fieldConfig+: { defaults+: { unit: default_unit } },
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
    }
}