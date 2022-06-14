# This is *LITERALLY* just copy/pasted from the private repository which currently contains the integrations.
# This needs to be moved to grafana/jsonnet-libs and integrations need to be refactored to fetch it from there as a dependency (jsonnetfile.json)
{
  decorate_dashboard(dashboard, tags, refresh='30s', timeFrom='now-30m')::
    dashboard {
      editable: false,
      id: null,  // If id is set the grafana client will try to update instead of create
      tags: tags,
      refresh: refresh,
      time: {
        from: timeFrom,
        to: 'now',
      },
      templating: {
        list+: [
          if std.objectHas(t, 'query') && t.query == 'prometheus' then t { regex: '(?!grafanacloud-usage|grafanacloud-ml-metrics).+' } else t
          for t in dashboard.templating.list
        ],
      },
    },
  prepare_dashboards(dashboards, tags, folderName, ignoreDashboards=[], refresh='30s', timeFrom='now-30m'):: {
    [k]: {
      dashboard: $.decorate_dashboard(dashboards[k], tags, refresh, timeFrom),
      folderId: 0,
      overwrite: true,
      folderName: folderName,
    }
    for k in std.objectFields(dashboards)
    if !std.member(ignoreDashboards, k)
  },
  prepare_alerts(namespace, prometheusAlerts, ignoreAlerts=[], ignoreAlertGroups=[])::
    {
      namespace: namespace,
    } +
    prometheusAlerts + {
      groups:
        std.map(function(el) el {
          rules:
            std.filter(function(r) !std.member(ignoreAlerts, r.alert), super.rules),
        }, std.filter(function(g) !std.member(ignoreAlertGroups, g.name), super.groups)),
    },
  prepare_rules(namespace, rules, ignoreRules=[], ignoreRuleGroups=[])::
    {
      namespace: namespace,
    } +
    rules + {
      groups:
        std.map(function(rr) rr {
          rules:
            std.filter(function(r) !std.member(ignoreRules, r.record), super.rules),
        }, std.filter(function(g) !std.member(ignoreRuleGroups, g.name), super.groups)),
    },
}
