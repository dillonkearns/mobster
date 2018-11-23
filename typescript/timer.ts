import { Elm } from "../src/Timer/Main";
import { remote, ipcRenderer, ipcMain } from "electron";

let flags = ipcRenderer.sendSync("timer-flags");
flags.isDev = process.env.NODE_ENV === "dev";

document.addEventListener("DOMContentLoaded", function(event) {
  let timer = Elm.Timer.Main.init({ flags: flags });

  document.getElementById("timer-window")!.addEventListener(
    "mouseenter",
    function(event) {
      ipcRenderer.send("timer-mouse-hover");
    },
    false
  );

  timer.ports.timerDone.subscribe(function(elapsedSeconds) {
    ipcRenderer.send("timer-done", elapsedSeconds);
  });

  timer.ports.breakTimerDone.subscribe(function(elapsedSeconds) {
    ipcRenderer.send("break-done", elapsedSeconds);
  });
});
