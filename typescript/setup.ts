import * as Elm from "../src/Setup/Main";
import { ipcRenderer, clipboard } from "electron";
const { version } = require("../package.json");
console.log(`Running version ${version}`);
let settingsJsonString: string | null = window.localStorage.getItem("settings");
let settings = settingsJsonString ? JSON.parse(settingsJsonString) : null;
let onMac = /Mac/.test(navigator.platform);
let isLocal = require("electron-is-dev");

document.addEventListener("DOMContentLoaded", function(event) {
  let setup = Elm.Elm.Setup.Main.init({ flags: { settings, onMac, isLocal } });
  setup.ports.selectDuration.subscribe(function(id) {
    let inputElement: any = document.getElementById(id);
    inputElement.select();
  });
  setup.ports.sendIpc.subscribe(function([message, data]) {
    console.log("sendIpc", message, data);
    ipcRenderer.send("elm-electron-ipc", { message, data });
  });
  setup.ports.saveSettings.subscribe(function(settings) {
    window.localStorage.setItem("settings", JSON.stringify(settings));
  });
  ipcRenderer.on("update-downloaded", function(
    event: any,
    updatedVersion: any
  ) {
    console.log("on update-downloaded. updatedVersion = ", updatedVersion);
    setup.ports.updateDownloaded.send("Not a real version...");
  });
  ipcRenderer.on("timer-done", function(event: any, elapsedSeconds: any) {
    setup.ports.timeElapsed.send(elapsedSeconds);
  });
  ipcRenderer.on("break-done", function(event: any, elapsedSeconds: any) {
    setup.ports.breakDone.send(elapsedSeconds);
  });
  $(() => {
    $(".invisible-trigger").hover(
      () => {
        $("body").addClass("transparent");
        ipcRenderer.send("transparent-hover-start");
      },
      () => {
        $("body").removeClass("transparent");
        ipcRenderer.send("transparent-hover-stop");
      }
    );
  });
});
