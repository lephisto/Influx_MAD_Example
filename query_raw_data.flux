//Query to show raw latency Values of a Ceph storage cluster

from(bucket: "mrmcd")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "ceph_daemon_stats")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["fsid"] == "YOUR-CLUSTER-FSID")
  |> filter(fn: (r) => r["ceph_daemon"] =~ /^osd.*$/)
  |> filter(fn: (r) => r["type_instance"] == "osd.op_r_latency")
  |> group(columns: ["ceph_daemon"], mode:"by")  
  |> toFloat()
  |> aggregateWindow(every: v.windowPeriod, fn: mean)
  |> derivative(unit: 1s, nonNegative: true)
