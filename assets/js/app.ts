// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"

// Import hooks for LiveView components.
import TerminalHook from "./hooks/terminal"
import PopoutHook from "./hooks/popout"
import EditorHook from "./hooks/editor"

// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import UserSocket from "./user_socket";

declare global {
  interface Window {
    liveSocket: LiveSocket,
    userSocket: Socket,
    userToken: string
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    EditorHook,
    TerminalHook,
    PopoutHook
  }
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", _info => topbar.show(300));
window.addEventListener("phx:page-loading-stop", _info => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
window.userSocket = UserSocket;

window.addEventListener("phx:close-window", _ => window.close());