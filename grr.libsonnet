local grr = import 'grizzly/grizzly.libsonnet';
local mixin = import 'mixin.libsonnet';
local dashboardFolder = '{{DASHBOARD_FOLDER}}';
local ruleNamespace = '{{RULE_NAMESPACE}}';
local dashboardId = std.asciiLower(std.strReplace(dashboardFolder, ' ', '-'));

{
  folders: [grr.folder.new(dashboardId, dashboardFolder)],
  dashboards: [
    grr.dashboard.new(mixin.grafanaDashboards[fname].uid, mixin.grafanaDashboards[fname]) +
    grr.resource.addMetadata('folder', dashboardId)
    for fname in std.objectFields(mixin.grafanaDashboards)
  ],
} +
if std.objectHasAll(mixin, 'prometheusRules') && std.length(mixin.prometheusRules) > 0 then
  {
    prometheus_rule_groups+: std.map(function(g) grr.rule_group.new(ruleNamespace, g.name, g), mixin.prometheusRules.groups),
  }
else
  {}
  +
  if std.objectHasAll(mixin, 'prometheusAlerts') && std.length(mixin.prometheusAlerts) > 0 then
    {
      prometheus_rule_groups+: std.map(function(g) grr.rule_group.new(ruleNamespace, g.name, g), mixin.prometheusAlerts.groups),
    } else {}
