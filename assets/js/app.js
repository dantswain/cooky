// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import {Socket} from "phoenix"

function onIngredientClick(ingredientId) {
  chan.push("ping", {})
    .receive("ok", (msg) => {
      console.log("PONG")
      console.log(msg)
    })

  console.log("Clicked " + ingredientId);
}

function setClickHandlers() {
  let ingredientListUL = document.getElementById("ingredient-list")
  let ingredientList = ingredientListUL.getElementsByTagName("li")

  for(let ix = 0; ix < ingredientList.length; ix++) {
    let li = ingredientList[ix]
    let link = li.getElementsByTagName("a")[0]
    let ingredientId = link.id.split("-")[1]
    link.onclick = function() {
      onIngredientClick(ingredientId)
    }
  }
}

function onJoin() {
  setClickHandlers()
}

let socket = new Socket("/socket", {
  logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data)  })
})
socket.connect();

socket.onOpen( ev => console.log("OPEN", ev)  )
socket.onError( ev => console.log("ERROR", ev)  )
socket.onClose( e => console.log("CLOSE", e) )

let chan = socket.channel("cooking:lobby", {})

chan.join()
  .receive("ignore", () => console.log("auth error"))
  .receive("ok", onJoin)

chan.on("")

chan.onError(e => console.log("something went wrong", e))
chan.onClose(e => console.log("channel closed", e))

