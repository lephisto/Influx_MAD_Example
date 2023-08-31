//Query to Display anomalies on Dicrete Panel for Grafana

import "contrib/anaisdg/anomalydetection"

from(bucket: "mrmcd")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "ceph_daemon_stats")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["fsid"] == "YOUR-CLUSTER-FSID")
  |> filter(fn: (r) => r["ceph_daemon"] =~ /^osd.*$/)
  |> filter(fn: (r) => r["type_instance"] == "osd.op_r_latency")
  |> group(columns: ["ceph_daemon"], mode:"by")
  |> toFloat()
  |> derivative(unit: 1s, nonNegative: true)
  |> aggregateWindow(every: v.windowPeriod, fn: mean)
  |> fill(value: 0.0)
  |> movingAverage(n:5)
  |> anomalydetection.mad(threshold:${thres})
  |> group(columns:["time","ceph_daemon"], mode:"by")
  |> map(fn: (r) => ({ r with
     _value:
       if r.level == "anomaly" then 1
       else 0 }))
  |> keep(columns: ["_measurement","_field","_value","_time","ceph_daemon"])
