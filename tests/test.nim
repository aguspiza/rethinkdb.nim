import asyncdispatch
import json

import ../rethinkdb


when isMainModule:
  var r = newRethinkClient(db="test")
  #var response = waitFor r.table("users").filter({"username": &"admin", "active": &true}).run()
  #echo($response)
  #response = waitFor r.table("users").get(response[0]["uid"].num.int).run()
  var response = waitFor r.table("pins").getAll(["89Mz49", "OlWdQR"], "a").run()
  echo($response)
  #r.disconnect()
