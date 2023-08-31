//Query to show MAD values

import "contrib/anaisdg/anomalydetection"

from(bucket: "mrmcd")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "ceph_daemon_stats")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["fsid"] == "YOURFSID")
  |> filter(fn: (r) => r["ceph_daemon"] =~ /^osd.*$/)
  |> filter(fn: (r) => r["type_instance"] == "osd.op_r_latency")
  |> group(columns: ["ceph_daemon"], mode:"by")
  |> toFloat()
  |> derivative(unit: 1s, nonNegative: true)
  |> aggregateWindow(every: v.windowPeriod, fn: mean)
  |> fill(value: 0.0)
  |> anomalydetection.mad(threshold:${thres})
  |> group(columns:["time","ceph_daemon"], mode:"by")
  |> keep(columns: ["_measurement","_field","_value","_time","ceph_daemon","level"])
  |> movingAverage(n:7)

