import nimuring
import std/[times]

const repeat = 1_000_000


type
  Event = object
    a: int
    b: int

proc run(entries: int) =
  var q = newQueue(entries, {})
  var count = 0
  # run 1 million nops to check queue throughput
  var time = cpuTime()
  while count < repeat:
      for i in 0..<entries:
        var ev: ptr Event
        when defined(userdata):
          ev = create(Event)
        else:
          ev = cast[ptr Event](i)
        q.nop(ev)
      q.submit()
      let cqes = q.copyCqes(entries.uint)
      when defined(userdata):
        for cqe in cqes:
          dealloc(cast[ptr Event](cqe.userData))
      count += cqes.len
  time = cpuTime() - time
  var rps = repeat / time
  echo q.params.sqEntries, " ", rps

for entries in @[64, 128, 256, 512, 1024, 2048, 4096]:
  run(entries)