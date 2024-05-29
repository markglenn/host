import { Terminal } from '@xterm/xterm';
import { FitAddon } from "@xterm/addon-fit";
import { Hook, makeHook } from 'phoenix_typed_hook';
import { Channel, Socket } from 'phoenix';

class TerminalHook extends Hook {
  terminal?: Terminal;
  channel?: Channel;

  mounted() {
    const socket = window['userSocket'] as Socket;

    // Connect to the terminal channel
    this.channel = socket.channel(`terminal:${this.el.dataset.type}:${this.el.dataset.topic}`, {
      container_id: this.el.dataset.containerId
    });

    this.channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) });

    this.terminal = new Terminal({
      convertEol: true
    });

    const fitAddon = new FitAddon();

    this.terminal.loadAddon(fitAddon);
    this.terminal.open(this.el);

    fitAddon.fit();

    // Handle reading a writing
    this.terminal.onData(data => this.channel?.push("write", { data }));
    this.channel.on("read", ({ content }) => this.terminal?.write(content));
    this.channel.on("closed", () => window.close());

    this.terminal.focus();

    // On cmd + k clear the terminal
    this.terminal.attachCustomKeyEventHandler(e => {
      if (e.key === 'k' && e.metaKey) {
        this.terminal?.clear();
        return false;
      }
      return true;
    });

    const observer = new ResizeObserver(() => {
      fitAddon.fit();
    });

    observer.observe(this.el);
  }

  destroyed() {
    this.terminal?.dispose();
  }
}

export default makeHook(TerminalHook);