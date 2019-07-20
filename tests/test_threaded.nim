import json, threadpool, unittest
import ../rethinkdb

setMaxPoolSize(64)

proc insert(c: int) : int =
    try:
      let jc = &*{"c": c}   
      var r = newRethinkClient()
      r.connect()
      r.repl()
      r.use("test")
      r.table("test").insert(jc).run(r, durability="soft")
      r.close()
      #force an exception
      #discard r.table("test").count().run().getInt()
      return c
    except:
      echo "error: " & getCurrentExceptionMsg()
      #raise #how do we handle this?

suite("threaded"):
  test("lots of inserts"):
    var r = newRethinkClient()
    r.connect()
    r.repl()
    r.use("test")
    let t = r.table("test")
    let before = t.count().run().getInt()

    let amount = 1000

    var tasks = newSeq[FlowVarBase](amount)
    for x in 1..amount:
      try:
        tasks[x-1] = spawn insert(x)
      except:
        #this not called when insert raises an exception
        echo "spawn error: " & getCurrentExceptionMsg()

    try :
      #wait for all threads to finish
      while true:
        var index = tasks.blockUntilAny()
        if index < 0:
          echo "All threads are ready"
          break
        #echo $(^FlowVar[int](tasks[index])), " done"
        tasks.del(index)

      let after = t.count().run().getInt()

      let expected = before + amount
      check after == expected
      r.close()
    except:
        #this not called when insert raises an exception
        echo "wait error: " & getCurrentExceptionMsg()
